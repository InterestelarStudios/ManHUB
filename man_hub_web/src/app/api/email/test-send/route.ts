import { NextRequest, NextResponse } from "next/server";
import { sendWelcomeEmail, sendPurchaseConfirmationEmail } from "@/lib/email/sendEmail";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { type, recipientEmail, userName } = body;

    if (!recipientEmail || !recipientEmail.includes("@")) {
      return NextResponse.json({ error: "E-mail inválido ou não fornecido." }, { status: 400 });
    }

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || "https://manhub.app";

    if (type === "welcome") {
      const res = await sendWelcomeEmail({
        userName: userName || "Membro VIP",
        userEmail: recipientEmail,
        appUrl,
      });
      return NextResponse.json(res);
    } else if (type === "purchase_training") {
      const res = await sendPurchaseConfirmationEmail({
        userName: userName || "Membro VIP",
        userEmail: recipientEmail,
        itemName: "O Homem Bem-Vestido: Alfaiataria & Proporção",
        itemType: "training",
        amount: 249.90,
        paymentId: "MP-TEST-982341",
        appUrl,
      });
      return NextResponse.json(res);
    } else if (type === "purchase_pass") {
      const res = await sendPurchaseConfirmationEmail({
        userName: userName || "Membro VIP",
        userEmail: recipientEmail,
        itemName: "Man Hub Pass (Acesso Ilimitado Recorrente)",
        itemType: "pass",
        amount: 49.90,
        paymentId: "SUB-TEST-554109",
        appUrl,
      });
      return NextResponse.json(res);
    }

    return NextResponse.json({ error: "Tipo de e-mail desconhecido" }, { status: 400 });
  } catch (error: any) {
    return NextResponse.json({ error: error?.message || "Erro ao disparar e-mail de teste" }, { status: 500 });
  }
}
