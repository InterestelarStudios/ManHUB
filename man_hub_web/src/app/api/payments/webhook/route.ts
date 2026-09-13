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
        console.warn("[Webhook] external_reference não era um JSON válido:", paymentData.external_reference);
      }

      const userId = ref?.userId;
      const itemType = ref?.itemType; // 'training' | 'pass'
      const itemId = ref?.itemId;

      // 1. Registra a ordem no Firestore para auditoria
      const orderRef = doc(db, "orders", String(paymentId));
      await setDoc(
        orderRef,
        {
          paymentId: String(paymentId),
          userId: userId || null,
          userEmail: ref?.userEmail || paymentData.payer?.email || null,
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

      // 2. Desbloqueia o conteúdo do usuário no Firestore
      if (userId) {
        const userRef = doc(db, "users", String(userId));
        const userSnap = await getDoc(userRef);

        if (itemType === "training" && itemId) {
          // Desbloqueia treinamento individual
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
                email: ref?.userEmail || paymentData.payer?.email || "",
                unlockedTrainingIds: [String(itemId)],
                memberType: "Membro Vitalício",
                updatedAt: serverTimestamp(),
              },
              { merge: true }
            );
          }
          console.log(`[Webhook] Treinamento ${itemId} desbloqueado para o usuário ${userId}`);
        } else if (itemType === "pass") {
          // Desbloqueia assinatura Man Hub Pass por 30 dias
          const expiresAt = new Date();
          expiresAt.setDate(expiresAt.getDate() + 30);

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
                email: ref?.userEmail || paymentData.payer?.email || "",
                isSubscribed: true,
                subscriptionExpiresAt: Timestamp.fromDate(expiresAt),
                memberType: "Assinante Man Hub Pass",
                updatedAt: serverTimestamp(),
              },
              { merge: true }
            );
          }
          console.log(`[Webhook] Man Hub Pass ativado por 30 dias para o usuário ${userId}`);
        }
      }
    }

    return NextResponse.json({ success: true, paymentId, status: paymentData.status }, { status: 200 });
  } catch (error: any) {
    console.error("[Webhook Exception] Erro inesperado:", error);
    return NextResponse.json({ error: error?.message || "Internal error" }, { status: 200 });
  }
}
