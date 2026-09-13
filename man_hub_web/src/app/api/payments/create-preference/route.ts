import { NextRequest, NextResponse } from "next/server";

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

    if (!userId || !itemType || !itemId || !price) {
      return NextResponse.json(
        { error: "Campos obrigatórios ausentes (userId, itemType, itemId, price)." },
        { status: 400, headers: { "Access-Control-Allow-Origin": "*" } }
      );
    }

    const accessToken = process.env.MERCADO_PAGO_ACCESS_TOKEN;
    if (!accessToken) {
      return NextResponse.json(
        { error: "MERCADO_PAGO_ACCESS_TOKEN não configurado no servidor." },
        { status: 500, headers: { "Access-Control-Allow-Origin": "*" } }
      );
    }

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";

    const externalReference = JSON.stringify({
      userId,
      userEmail: userEmail || "",
      itemType,
      itemId,
    });

    const preferencePayload = {
      items: [
        {
          id: String(itemId),
          title: String(title || "Conteúdo Man Hub"),
          description: String(description || "Acesso exclusivo Man Hub"),
          quantity: 1,
          currency_id: "BRL",
          unit_price: Number(price),
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
      ...(appUrl && !appUrl.includes("localhost")
        ? { notification_url: `${appUrl}/api/payments/webhook` }
        : {}),
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
