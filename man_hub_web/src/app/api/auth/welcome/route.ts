import { NextRequest, NextResponse } from "next/server";
import { sendWelcomeEmail } from "@/lib/email/sendEmail";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { userEmail, userName } = body;

    if (!userEmail) {
      return NextResponse.json({ error: "E-mail não fornecido" }, { status: 400 });
    }

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || "https://manhub.app";
    const result = await sendWelcomeEmail({
      userEmail,
      userName,
      appUrl,
    });

    return NextResponse.json(result, { status: 200 });
  } catch (error: any) {
    console.error("[Welcome Email API] Erro ao processar requisição:", error);
    return NextResponse.json({ error: error?.message || "Erro interno" }, { status: 500 });
  }
}
