import { NextRequest, NextResponse } from "next/server";
import { db } from "@/lib/firebase";
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  arrayUnion,
  serverTimestamp,
  Timestamp,
  collection,
  query,
  where,
  getDocs,
} from "firebase/firestore";

export async function POST(req: NextRequest) {
  try {
    const url = new URL(req.url);
    const queryTopic = url.searchParams.get("topic") || url.searchParams.get("type");
    const queryId = url.searchParams.get("id") || url.searchParams.get("data.id");

    let bodyData: any = {};
    try {
      bodyData = await req.json();
    } catch (_) {
      // Alguns webhooks do Mercado Pago enviam apenas query params
    }

    const topic = queryTopic || bodyData.type || bodyData.topic || bodyData.action;
    const paymentId = queryId || bodyData.data?.id || bodyData.id;

    console.log(`[Mercado Pago Webhook] Recebido topic: ${topic}, id: ${paymentId}`);

    if (!paymentId) {
      // Retorna 200 para o Mercado Pago não reenviar em loop caso seja ping de teste
      return NextResponse.json({ received: true, message: "ID não fornecido." }, { status: 200 });
    }

    // Se a notificação não for de pagamento (ex: merchant_order), responde 200
    if (topic && !topic.includes("payment")) {
      return NextResponse.json({ received: true, ignored: topic }, { status: 200 });
    }

    const accessToken = process.env.MERCADO_PAGO_ACCESS_TOKEN;
    if (!accessToken) {
      console.error("[Webhook Error] MERCADO_PAGO_ACCESS_TOKEN não configurado.");
      return NextResponse.json({ error: "Access token missing" }, { status: 500 });
    }

    // Consulta autorizada diretamente na API oficial do Mercado Pago para verificação do pagamento
    const mpRes = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
    });

    if (!mpRes.ok) {
      const errText = await mpRes.text();
      console.error(`[Webhook Error] Falha ao consultar pagamento ${paymentId}:`, errText);
      return NextResponse.json({ error: "Erro ao consultar pagamento no MP" }, { status: 200 });
    }

    const paymentData = await mpRes.json();
    console.log(`[Webhook] Pagamento ${paymentId} status: ${paymentData.status}`);

    // Processa apenas se o pagamento estiver APROVADO
    if (paymentData.status === "approved") {
      let ref: any = null;
      try {
        if (paymentData.external_reference) {
          ref = JSON.parse(paymentData.external_reference);
        }
      } catch (e) {
        // Fallback caso venha no formato userId___itemType___itemId
        const parts = String(paymentData.external_reference || "").split("___");
        if (parts.length >= 2) {
          ref = {
            userId: parts[0],
            itemType: parts[1],
            itemId: parts.length >= 3 ? parts[2] : undefined,
          };
        }
      }

      const metadata = paymentData.metadata || {};
      const userId = ref?.userId || metadata.user_id;
      let itemType = ref?.itemType || metadata.item_type; // 'training' | 'pass'
      const itemId = ref?.itemId || metadata.item_id;
      const payerEmail = (ref?.userEmail || metadata.user_email || paymentData.payer?.email || "")
        .trim()
        .toLowerCase();

      if (!itemType && paymentData.description && paymentData.description.includes("Man Hub Pass")) {
        itemType = "pass";
      }

      // 1. Registra a ordem no Firestore para auditoria
      const orderRef = doc(db, "orders", String(paymentId));
      await setDoc(
        orderRef,
        {
          paymentId: String(paymentId),
          userId: userId || null,
          userEmail: payerEmail || null,
          payerEmail: payerEmail || null,
          itemType: itemType || "unknown",
          itemId: itemId || null,
          transactionAmount: paymentData.transaction_amount,
          status: paymentData.status,
          statusDetail: paymentData.status_detail,
          paymentMethodId: paymentData.payment_method_id,
          paymentTypeId: paymentData.payment_type_id,
          dateApproved: paymentData.date_approved ? new Date(paymentData.date_approved) : new Date(),
          rawPaymentData: {
            id: paymentData.id,
            collector_id: paymentData.collector_id,
            currency_id: paymentData.currency_id,
            installments: paymentData.installments,
          },
          updatedAt: serverTimestamp(),
        },
        { merge: true }
      );

      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 32);

      // 2. Registra o entitlement por e-mail para sincronização imediata
      if (payerEmail) {
        const entRef = doc(db, "entitlements", payerEmail);
        if (itemType === "training" && itemId) {
          await setDoc(
            entRef,
            {
              email: payerEmail,
              unlockedTrainingIds: arrayUnion(String(itemId)),
              updatedAt: serverTimestamp(),
            },
            { merge: true }
          );
        } else if (itemType === "pass") {
          await setDoc(
            entRef,
            {
              email: payerEmail,
              isSubscribed: true,
              subscriptionExpiresAt: Timestamp.fromDate(expiresAt),
              updatedAt: serverTimestamp(),
            },
            { merge: true }
          );
        }

        // 3. Atualiza usuários que já possuam esse e-mail no Firestore
        try {
          const usersQ = query(collection(db, "users"), where("email", "==", payerEmail));
          const usersSnap = await getDocs(usersQ);
          for (const userDoc of usersSnap.docs) {
            if (itemType === "training" && itemId) {
              await updateDoc(userDoc.ref, {
                unlockedTrainingIds: arrayUnion(String(itemId)),
                updatedAt: serverTimestamp(),
              });
            } else if (itemType === "pass") {
              await updateDoc(userDoc.ref, {
                isSubscribed: true,
                subscriptionExpiresAt: Timestamp.fromDate(expiresAt),
                memberType: "Assinante Man Hub Pass",
                updatedAt: serverTimestamp(),
              });
            }
          }
        } catch (uErr) {
          console.warn("[Webhook] Aviso ao atualizar usuários por email:", uErr);
        }
      }

      // 4. Se houver userId direto, atualiza o documento correspondente
      if (userId) {
        const userRef = doc(db, "users", String(userId));
        const userSnap = await getDoc(userRef);

        if (itemType === "training" && itemId) {
          if (userSnap.exists()) {
            await updateDoc(userRef, {
              unlockedTrainingIds: arrayUnion(String(itemId)),
              updatedAt: serverTimestamp(),
            });
          } else {
            await setDoc(
              userRef,
              {
                uid: String(userId),
                email: payerEmail,
                unlockedTrainingIds: [String(itemId)],
                memberType: "Membro Vitalício",
                updatedAt: serverTimestamp(),
              },
              { merge: true }
            );
          }
        } else if (itemType === "pass") {
          if (userSnap.exists()) {
            await updateDoc(userRef, {
              isSubscribed: true,
              subscriptionExpiresAt: Timestamp.fromDate(expiresAt),
              memberType: "Assinante Man Hub Pass",
              updatedAt: serverTimestamp(),
            });
          } else {
            await setDoc(
              userRef,
              {
                uid: String(userId),
                email: payerEmail,
                isSubscribed: true,
                subscriptionExpiresAt: Timestamp.fromDate(expiresAt),
                memberType: "Assinante Man Hub Pass",
                updatedAt: serverTimestamp(),
              },
              { merge: true }
            );
          }
        }
      }
    }

    return NextResponse.json({ success: true, paymentId, status: paymentData.status }, { status: 200 });
  } catch (error: any) {
    console.error("[Webhook Exception] Erro inesperado:", error);
    return NextResponse.json({ error: error?.message || "Internal error" }, { status: 200 });
  }
}
