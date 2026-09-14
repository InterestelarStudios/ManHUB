import { NextRequest, NextResponse } from "next/server";
import { db } from "@/lib/firebase";
import { collection, addDoc } from "firebase/firestore";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { email, reason, confirmationCode } = body;

    if (!email || typeof email !== "string" || !email.includes("@")) {
      return NextResponse.json(
        { error: "E-mail inválido ou não informado." },
        { status: 400 }
      );
    }

    const requestData = {
      email: email.trim().toLowerCase(),
      reason: (reason || "").toString().trim(),
      confirmationCode: confirmationCode || `DEL-${Date.now().toString(36).toUpperCase()}`,
      status: "pending",
      source: "web_form",
      createdAt: new Date().toISOString(),
      userAgent: req.headers.get("user-agent") || "unknown",
    };

    // Salva na coleção de solicitações de exclusão no Firestore
    const docRef = await addDoc(collection(db, "account_deletion_requests"), requestData);

    return NextResponse.json({
      success: true,
      protocol: requestData.confirmationCode,
      id: docRef.id,
      message: "Solicitação de exclusão registrada com sucesso.",
    });
  } catch (error) {
    console.error("Erro ao registrar solicitação de exclusão:", error);
    return NextResponse.json(
      { error: "Ocorreu um erro interno ao processar a solicitação. Tente novamente ou envie um e-mail para support@interestelar.studio." },
      { status: 500 }
    );
  }
}
