const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const cors = require("cors")({origin: true});

admin.initializeApp();
const db = admin.firestore();

setGlobalOptions({maxInstances: 10, region: "us-central1"});

const MERCADO_PAGO_ACCESS_TOKEN =
  process.env.MERCADO_PAGO_ACCESS_TOKEN ||
  "APP_USR-8650319085401470-091313-c630ac030866e528147d4d0f19560f7e-1846525827";

const APP_URL =
  process.env.APP_URL || "https://man-hub-c0bef.web.app";

const WEBHOOK_URL =
  process.env.MERCADO_PAGO_WEBHOOK_URL ||
  "https://us-central1-man-hub-c0bef.cloudfunctions.net/mercadoPagoWebhook";

/**
 * Cria ou Assinatura Recorrente (/preapproval) para o Man Hub Pass
 * ou Preferência de Compra Avulsa (/checkout/preferences) para Cursos.
 */
exports.createPaymentPreference = onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({error: "Method Not Allowed"});
    }

    try {
      const {
        userId,
        userEmail,
        userName,
        itemType, // "pass" | "training"
        itemId, // "man_hub_pass" | id do treinamento
        title,
        price,
      } = req.body;

      if (!userId || !itemType || !itemId) {
        return res.status(400).json({
          error: "Campos obrigatórios ausentes (userId, itemType, itemId).",
        });
      }

      // =======================================================================
      // 1. ASSINATURA RECORRENTE MENSAL (MAN HUB PASS) -> PREAPPROVAL
      // Cobrança automática mensal sem parcelamento
      // =======================================================================
      if (itemType === "pass") {
        const subscriptionPayload = {
          reason: "Man Hub Pass (Acesso Ilimitado)",
          auto_recurring: {
            frequency: 1,
            frequency_type: "months",
            transaction_amount: 49.90,
            currency_id: "BRL",
          },
          back_url: `${APP_URL}/payment/subscription`,
          payer_email:
            userEmail && userEmail.includes("@") ?
              userEmail.trim() :
              "contato@manhub.com.br",
          external_reference: `${userId}___pass___man_hub_pass`,
          status: "pending",
        };

        logger.info(
            "Criando assinatura recorrente no Mercado Pago (/preapproval):",
            subscriptionPayload,
        );

        const subResponse = await fetch(
            "https://api.mercadopago.com/preapproval",
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${MERCADO_PAGO_ACCESS_TOKEN}`,
              },
              body: JSON.stringify(subscriptionPayload),
            },
        );

        if (!subResponse.ok) {
          const subError = await subResponse.text();
          logger.error(
              "Erro do Mercado Pago ao criar assinatura recorrente:",
              subError,
          );
          return res.status(subResponse.status).json({
            error: "Erro ao gerar assinatura recorrente no Mercado Pago.",
            details: subError,
          });
        }

        const subData = await subResponse.json();
        logger.info(
            `Assinatura recorrente gerada: ${subData.id} - R$ 49.90/mês`,
        );

        return res.status(200).json({
          preferenceId: subData.id,
          initPoint: subData.init_point,
          sandboxInitPoint: subData.sandbox_init_point,
          finalPrice: 49.90,
          isSubscription: true,
        });
      }

      // =======================================================================
      // 2. COMPRA AVULSA DE TREINAMENTO VITALÍCIO -> PREFERENCES
      // Checkout Pro tradicional (Pix, Cartão, Boleto, Parcelamento opcional)
      // =======================================================================
      let finalPrice = Number(price) || 97.0;
      let finalTitle = title || "Treinamento Man Hub";

      if (itemId) {
        try {
          const docRef = db.collection("trainings").doc(itemId);
          const trainingDoc = await docRef.get();
          if (trainingDoc.exists) {
            const data = trainingDoc.data();
            if (data && data.price && Number(data.price) > 0) {
              finalPrice = Number(data.price);
            }
            if (data && data.title) {
              finalTitle = `Acesso Vitalício: ${data.title}`;
            }
          }
        } catch (dbErr) {
          logger.warn(
              `Aviso: Falha ao consultar preço do curso ${itemId}:`,
              dbErr,
          );
        }
      }

      finalPrice = Number(finalPrice.toFixed(2));

      const preferencePayload = {
        items: [
          {
            id: String(itemId),
            title: String(finalTitle),
            description: `Acesso vitalício ao curso: ${finalTitle}`,
            quantity: 1,
            currency_id: "BRL",
            unit_price: finalPrice,
          },
        ],
        payer: {
          name: userName || "Membro Man Hub",
          email: userEmail || "contato@manhub.com.br",
        },
        back_urls: {
          success: `${APP_URL}/payment/success`,
          pending: `${APP_URL}/payment/pending`,
          failure: `${APP_URL}/payment/failure`,
        },
        notification_url: WEBHOOK_URL,
        external_reference: `${userId}___training___${itemId}`,
        metadata: {
          user_id: userId,
          item_type: "training",
          item_id: itemId,
        },
      };

      const mpResponse = await fetch(
          "https://api.mercadopago.com/checkout/preferences",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${MERCADO_PAGO_ACCESS_TOKEN}`,
            },
            body: JSON.stringify(preferencePayload),
          },
      );

      if (!mpResponse.ok) {
        const errorDetails = await mpResponse.text();
        logger.error(
            "Erro retornado pelo Mercado Pago para preferência avulsa:",
            errorDetails,
        );
        return res.status(mpResponse.status).json({
          error: "Erro ao gerar preferência no Mercado Pago.",
          details: errorDetails,
        });
      }

      const mpData = await mpResponse.json();
      logger.info(
          `Preferência avulsa gerada: ${mpData.id} - R$ ${finalPrice}`,
      );

      return res.status(200).json({
        preferenceId: mpData.id,
        initPoint: mpData.init_point,
        sandboxInitPoint: mpData.sandbox_init_point,
        finalPrice: finalPrice,
        isSubscription: false,
      });
    } catch (err) {
      logger.error("Erro interno ao criar preferência/assinatura:", err);
      return res.status(500).json({
        error: "Erro interno do servidor.",
        message: err.message,
      });
    }
  });
});

/**
 * Webhook oficial para receber notificações do Mercado Pago.
 * Suporta:
 *  - Eventos de Assinatura Recorrente (subscription_preapproval)
 *  - Eventos de Pagamentos (payment) - compras avulsas e débitos de recorrência
 */
exports.mercadoPagoWebhook = onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const {query, body} = req;
      logger.info("Notificação Webhook MP recebida:", {query, body});

      const topic =
        query.topic ||
        query.type ||
        body.type ||
        body.topic ||
        (body.action && body.action.includes("subscription") ?
          "subscription_preapproval" :
          null);

      const dataId =
        query.id ||
        query["data.id"] ||
        (body.data && body.data.id) ||
        body.id;

      if (!dataId) {
        logger.info("Notificação ignorada: ID não identificado.");
        return res.status(200).send("Ignored");
      }

      // =======================================================================
      // CASO A: NOTIFICAÇÃO DE ASSINATURA RECORRENTE (PREAPPROVAL)
      // =======================================================================
      const isSubscriptionTopic =
        topic === "subscription_preapproval" ||
        topic === "preapproval" ||
        String(dataId).startsWith("2c93");

      if (isSubscriptionTopic) {
        logger.info(`Processando assinatura recorrente: ${dataId}`);
        const subRes = await fetch(
            `https://api.mercadopago.com/preapproval/${dataId}`,
            {
              headers: {
                Authorization: `Bearer ${MERCADO_PAGO_ACCESS_TOKEN}`,
              },
            },
        );

        if (subRes.ok) {
          const subData = await subRes.json();
          logger.info(
              `Status da assinatura ${dataId}: ${subData.status}`,
              subData,
          );

          let userId = null;
          if (subData.external_reference) {
            const parts = String(subData.external_reference).split("___");
            if (parts.length >= 1) {
              userId = parts[0];
            }
          }

          if (userId) {
            const userRef = db.collection("users").doc(userId);
            const now = new Date();

            if (subData.status === "authorized") {
              // Assinatura ativa! Ciclo mensal renovado
              const expiresAt = new Date(
                  now.getTime() + 32 * 24 * 60 * 60 * 1000,
              );
              await userRef.set(
                  {
                    isSubscribed: true,
                    subscriptionId: String(dataId),
                    subscriptionStatus: "authorized",
                    subscriptionExpiresAt:
                      admin.firestore.Timestamp.fromDate(expiresAt),
                    memberType: "Assinante Man Hub Pass",
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                  },
                  {merge: true},
              );

              // Salva registro em collection subscriptions
              await db.collection("subscriptions").doc(String(dataId)).set(
                  {
                    subscriptionId: String(dataId),
                    userId: userId,
                    status: subData.status,
                    reason: subData.reason || "Man Hub Pass",
                    amount:
                      subData.auto_recurring ?
                        subData.auto_recurring.transaction_amount :
                        49.90,
                    payerEmail: subData.payer_email || "",
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                  },
                  {merge: true},
              );

              if (subData.payer_email) {
                const normEmail = subData.payer_email.trim().toLowerCase();
                await db.collection("entitlements").doc(normEmail).set(
                    {
                      email: normEmail,
                      isSubscribed: true,
                      subscriptionExpiresAt:
                        admin.firestore.Timestamp.fromDate(expiresAt),
                      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    },
                    {merge: true},
                );
              }

              logger.info(
                  `Assinatura ${dataId} AUTORIZADA para ${userId}`,
              );
            } else if (
              subData.status === "cancelled" ||
              subData.status === "paused"
            ) {
              await userRef.set(
                  {
                    isSubscribed: false,
                    subscriptionStatus: subData.status,
                    memberType: "Visitante",
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                  },
                  {merge: true},
              );

              await db.collection("subscriptions").doc(String(dataId)).set(
                  {
                    status: subData.status,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                  },
                  {merge: true},
              );

              logger.info(
                  `Assinatura ${dataId} ${subData.status} para ${userId}`,
              );
            }
          }
        } else {
          logger.error(
              `Erro ao consultar preapproval ${dataId}: ${subRes.status}`,
          );
        }

        return res.status(200).send("Subscription Notification Processed");
      }

      // =======================================================================
      // CASO B: NOTIFICAÇÃO DE PAGAMENTO (AVULSO OU DÉBITOS DE ASSINATURA)
      // =======================================================================
      const paymentId = dataId;
      const mpResponse = await fetch(
          `https://api.mercadopago.com/v1/payments/${paymentId}`,
          {
            headers: {
              Authorization: `Bearer ${MERCADO_PAGO_ACCESS_TOKEN}`,
            },
          },
      );

      if (!mpResponse.ok) {
        logger.error(
            `Erro ao consultar pagamento ${paymentId}: ${mpResponse.status}`,
        );
        return res.status(200).send("Payment fetch error");
      }

      const paymentData = await mpResponse.json();
      logger.info(`Pagamento ${paymentId} status: ${paymentData.status}`);

      const metadata = paymentData.metadata || {};
      let userId = metadata.user_id;
      let itemType = metadata.item_type;
      let itemId = metadata.item_id;

      // Fallback para external_reference
      if ((!userId || !itemType) && paymentData.external_reference) {
        try {
          const parsed = JSON.parse(paymentData.external_reference);
          userId = parsed.userId || userId;
          itemType = parsed.itemType || itemType;
          itemId = parsed.itemId || itemId;
        } catch (_) {
          const parts = String(paymentData.external_reference).split("___");
          if (parts.length >= 2) {
            userId = parts[0];
            itemType = parts[1];
            if (parts.length >= 3) itemId = parts[2];
          }
        }
      }

      // Pagamento originado de assinatura recorrente Man Hub Pass
      if (
        !itemType &&
        paymentData.description &&
        paymentData.description.includes("Man Hub Pass")
      ) {
        itemType = "pass";
      }

      if (paymentData.status === "approved" && userId) {
        const userRef = db.collection("users").doc(userId);
        const now = new Date();

        if (itemType === "pass") {
          const expiresAt = new Date(now.getTime() + 32 * 24 * 60 * 60 * 1000);
          await userRef.set(
              {
                isSubscribed: true,
                subscriptionExpiresAt:
                  admin.firestore.Timestamp.fromDate(expiresAt),
                memberType: "Assinante Man Hub Pass",
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              {merge: true},
          );
          logger.info(`Mensalidade aprovada/renovada para usuário ${userId}`);
        } else if (itemType === "training" && itemId) {
          await userRef.set(
              {
                unlockedTrainingIds:
                  admin.firestore.FieldValue.arrayUnion(itemId),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              {merge: true},
          );
          logger.info(
              `Treinamento vitalício ${itemId} desbloqueado para ${userId}`,
          );
        }

        const payerEmail = (
          (paymentData.payer && paymentData.payer.email) ||
          ""
        ).trim().toLowerCase();

        // Grava entitlement e atualiza usuários correspondentes por e-mail
        if (payerEmail) {
          const entRef = db.collection("entitlements").doc(payerEmail);
          if (itemType === "pass") {
            const expiresAt = new Date(now.getTime() + 32 * 24 * 60 * 60 * 1000);
            await entRef.set({
              email: payerEmail,
              isSubscribed: true,
              subscriptionExpiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, {merge: true});
          } else if (itemType === "training" && itemId) {
            await entRef.set({
              email: payerEmail,
              unlockedTrainingIds: admin.firestore.FieldValue.arrayUnion(itemId),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, {merge: true});
          }

          try {
            const userSnaps = await db.collection("users").where("email", "==", payerEmail).get();
            for (const docSnap of userSnaps.docs) {
              if (itemType === "pass") {
                const expiresAt = new Date(now.getTime() + 32 * 24 * 60 * 60 * 1000);
                await docSnap.ref.set({
                  isSubscribed: true,
                  subscriptionExpiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
                  memberType: "Assinante Man Hub Pass",
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                }, {merge: true});
              } else if (itemType === "training" && itemId) {
                await docSnap.ref.set({
                  unlockedTrainingIds: admin.firestore.FieldValue.arrayUnion(itemId),
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                }, {merge: true});
              }
            }
          } catch (e) {
            logger.warn("Aviso ao sincronizar usuarios por email:", e);
          }
        }

        // Salva histórico de transação auditável no Firestore
        await db.collection("orders").doc(String(paymentId)).set({
          paymentId: String(paymentId),
          userId: userId,
          itemType: itemType || "unknown",
          itemId: itemId || "unknown",
          amount: paymentData.transaction_amount || 0,
          status: paymentData.status,
          paymentMethod: paymentData.payment_method_id || "unknown",
          payerEmail: payerEmail,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else if (
        (paymentData.status === "refunded" ||
          paymentData.status === "charged_back") &&
        userId
      ) {
        const userRef = db.collection("users").doc(userId);
        if (itemType === "pass") {
          await userRef.set(
              {
                isSubscribed: false,
                memberType: "Visitante",
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              {merge: true},
          );
          logger.info(`Assinatura revogada por estorno para ${userId}`);
        } else if (itemType === "training" && itemId) {
          await userRef.set(
              {
                unlockedTrainingIds:
                  admin.firestore.FieldValue.arrayRemove(itemId),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              {merge: true},
          );
          logger.info(`Curso ${itemId} revogado por estorno para ${userId}`);
        }

        await db.collection("orders").doc(String(paymentId)).set(
            {
              status: paymentData.status,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            {merge: true},
        );
      }

      return res.status(200).send("OK");
    } catch (err) {
      logger.error("Erro no processamento do webhook:", err);
      return res.status(500).send("Internal Server Error");
    }
  });
});
