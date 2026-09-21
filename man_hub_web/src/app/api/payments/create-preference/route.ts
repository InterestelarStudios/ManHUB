import { NextRequest, NextResponse } from "next/server";
import { db } from "@/lib/firebase";
import { doc, getDoc } from "firebase/firestore";

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    },
  });
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const {
      userId,
      userEmail,
      userName,
      itemType, // 'training' | 'pass'
      itemId,   // trainingId ou 'man_hub_pass'
      title,
      description,
      price,
    } = body;

    if (!userId || !itemType || !itemId) {
      return NextResponse.json(
        { error: "Campos obrigatórios ausentes (userId, itemType, itemId)." },
        { status: 400, headers: { "Access-Control-Allow-Origin": "*" } }
      );
    }

    const accessToken = process.env.MERCADO_PAGO_ACCESS_TOKEN || "APP_USR-8650319085401470-091313-c630ac030866e528147d4d0f19560f7e-1846525827";
    const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";
    const webhookUrl =
      process.env.MERCADO_PAGO_WEBHOOK_URL ||
      "https://us-central1-man-hub-c0bef.cloudfunctions.net/mercadoPagoWebhook";

    // =========================================================================
    // 1. ASSINATURA RECORRENTE MENSAL (MAN HUB PASS) -> MERCADO PAGO PREAPPROVAL
    // =========================================================================
    if (itemType === "pass") {
      // Mercado Pago Preapproval exige estritamente uma URL pública com protocolo HTTPS para o back_url
      let subBackUrl = `${appUrl}/payment/success`;
      if (!subBackUrl.startsWith("https://") || subBackUrl.includes("localhost") || subBackUrl.includes("127.0.0.1")) {
        subBackUrl = "https://manhub.app/payment/success";
      }

      // Validação do email do pagador para a API de assinaturas do MP
      const validEmailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      const cleanUserEmail =
        userEmail && validEmailRegex.test(userEmail.trim())
          ? userEmail.trim().toLowerCase()
          : "contato@manhub.app";

      // Obtenção dinâmica do valor da assinatura no Firestore
      let transactionAmount = 49.90;
      try {
        const planDoc = await getDoc(doc(db, "plans", "man_hub_pass"));
        if (planDoc.exists()) {
          const planData = planDoc.data();
          if (typeof planData.price === "number" && planData.price > 0) {
            transactionAmount = planData.price;
          } else if (planData.price) {
            const n = Number(planData.price);
            if (!isNaN(n) && n > 0) transactionAmount = n;
          }
        } else if (price && !isNaN(Number(price)) && Number(price) > 0) {
          transactionAmount = Number(price);
        }
      } catch (e) {
        console.warn("Erro ao buscar plano no Firestore:", e);
        if (price && !isNaN(Number(price)) && Number(price) > 0) {
          transactionAmount = Number(price);
        }
      }

      const subscriptionPayload = {
        reason: "Man Hub Pass (Acesso Ilimitado)",
        auto_recurring: {
          frequency: 1,
          frequency_type: "months",
          transaction_amount: transactionAmount,
          currency_id: "BRL",
        },
        back_url: subBackUrl,
        payer_email: cleanUserEmail,
        external_reference: `${userId}___pass___man_hub_pass`,
        status: "pending",
      };

      const subResponse = await fetch("https://api.mercadopago.com/preapproval", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(subscriptionPayload),
      });

      if (!subResponse.ok) {
        const errData = await subResponse.text();
        console.error("Erro ao criar assinatura recorrente no Mercado Pago:", errData);
        let errorMsg = "Erro ao gerar assinatura no Mercado Pago";
        try {
          const jsonErr = JSON.parse(errData);
          if (jsonErr.message) {
            errorMsg = `Mercado Pago: ${jsonErr.message}`;
          }
        } catch (_) {}
        return NextResponse.json(
          { error: errorMsg, details: errData },
          { status: subResponse.status, headers: { "Access-Control-Allow-Origin": "*" } }
        );
      }

      const subData = await subResponse.json();

      return NextResponse.json(
        {
          preferenceId: subData.id,
          initPoint: subData.init_point,
          sandboxInitPoint: subData.sandbox_init_point,
          finalPrice: transactionAmount,
          isSubscription: true,
        },
        {
          status: 200,
          headers: { "Access-Control-Allow-Origin": "*" },
        }
      );
    }

    // =========================================================================
    // 2. COMPRA AVULSA DE TREINAMENTO VITALÍCIO -> MERCADO PAGO PREFERENCES
    // =========================================================================
    let finalPrice = Number(price) || 97.0;
    let finalTitle = title || "Conteúdo Man Hub";

    if (itemId) {
      try {
        const trainingSnap = await getDoc(doc(db, "trainings", String(itemId)));
        if (trainingSnap.exists()) {
          const data = trainingSnap.data();
          if (data && data.price && Number(data.price) > 0) {
            finalPrice = Number(data.price);
          }
          if (data && data.title) {
            finalTitle = `Acesso Vitalício: ${data.title}`;
          }
        }
      } catch (err) {
        console.warn("[Preference] Erro ao consultar preço do treinamento no Firestore:", err);
      }
    }

    finalPrice = Number(finalPrice.toFixed(2));

    const externalReference = `${userId}___training___${itemId}`;

    const preferencePayload = {
      items: [
        {
          id: String(itemId),
          title: String(finalTitle),
          description: String(
            description || `Acesso vitalício: ${finalTitle}`
          ),
          quantity: 1,
          currency_id: "BRL",
          unit_price: finalPrice,
        },
      ],
      payer: {
        name: userName || "Membro Man Hub",
        email: userEmail || "cliente@manhub.app",
      },
      back_urls: {
        success: `${appUrl}/payment/success`,
        failure: `${appUrl}/payment/failure`,
        pending: `${appUrl}/payment/pending`,
      },
      external_reference: externalReference,
      notification_url: webhookUrl,
      statement_descriptor: "MAN HUB",
    };

    const mpResponse = await fetch("https://api.mercadopago.com/checkout/preferences", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(preferencePayload),
    });

    if (!mpResponse.ok) {
      const errData = await mpResponse.text();
      console.error("Erro retornado pelo Mercado Pago ao criar preferência:", errData);
      return NextResponse.json(
        { error: "Erro ao gerar preferência no Mercado Pago", details: errData },
        { status: mpResponse.status, headers: { "Access-Control-Allow-Origin": "*" } }
      );
    }

    const preference = await mpResponse.json();

    return NextResponse.json(
      {
        preferenceId: preference.id,
        initPoint: preference.init_point,
        sandboxInitPoint: preference.sandbox_init_point,
        finalPrice: finalPrice,
        isSubscription: false,
      },
      {
        status: 200,
        headers: { "Access-Control-Allow-Origin": "*" },
      }
    );
  } catch (error: any) {
    console.error("Erro interno ao criar preferência:", error);
    return NextResponse.json(
      { error: "Erro interno no servidor ao criar preferência", message: error?.message },
      { status: 500, headers: { "Access-Control-Allow-Origin": "*" } }
    );
  }
}
