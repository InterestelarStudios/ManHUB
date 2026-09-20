import { Resend } from "resend";
import {
  getWelcomeEmailHtml,
  getPurchaseConfirmationEmailHtml,
  WelcomeEmailData,
  PurchaseConfirmationEmailData,
} from "./emailTemplates";

const resendApiKey = process.env.RESEND_API_KEY;
const resend = resendApiKey ? new Resend(resendApiKey) : null;

// Remetente padrão: usa a variável de ambiente ou o remetente oficial
const defaultFrom = process.env.EMAIL_FROM || "MAN HUB <contato@manhub.app>";

/**
 * Envia o e-mail oficial de boas-vindas após a criação da conta
 */
export async function sendWelcomeEmail(data: WelcomeEmailData) {
  if (!data.userEmail) {
    console.warn("[Email Service] E-mail de destino ausente para boas-vindas.");
    return { success: false, error: "Destinatário não informado" };
  }

  const html = getWelcomeEmailHtml(data);
  const subject = "🔥 Bem-vindo ao MAN HUB! Sua jornada de evolução começou";

  if (!resend) {
    console.info(
      `[Email Service (Simulado)] RESEND_API_KEY não configurada. E-mail de boas-vindas para: ${data.userEmail}`
    );
    return { success: true, simulated: true };
  }

  try {
    const result = await resend.emails.send({
      from: defaultFrom,
      to: data.userEmail,
      subject,
      html,
    });

    console.log(`[Email Service] E-mail de boas-vindas enviado com sucesso para ${data.userEmail}:`, result);
    return { success: true, result };
  } catch (error: any) {
    console.error(`[Email Service] Falha ao enviar e-mail de boas-vindas para ${data.userEmail}:`, error);
    return { success: false, error: error?.message || "Falha no envio de e-mail" };
  }
}

/**
 * Envia o e-mail oficial de confirmação e agradecimento de compra
 */
export async function sendPurchaseConfirmationEmail(data: PurchaseConfirmationEmailData) {
  if (!data.userEmail) {
    console.warn("[Email Service] E-mail de destino ausente para confirmação de compra.");
    return { success: false, error: "Destinatário não informado" };
  }

  const html = getPurchaseConfirmationEmailHtml(data);
  const subject =
    data.itemType === "pass"
      ? "⚡ Bem-vindo ao Man Hub Pass! Seu acesso ilimitado está liberado"
      : `🔥 Compra Confirmada: Seu treinamento "${data.itemName}" está liberado!`;

  if (!resend) {
    console.info(
      `[Email Service (Simulado)] RESEND_API_KEY não configurada. E-mail de compra para: ${data.userEmail} (${data.itemName})`
    );
    return { success: true, simulated: true };
  }

  try {
    const result = await resend.emails.send({
      from: defaultFrom,
      to: data.userEmail,
      subject,
      html,
    });

    console.log(`[Email Service] E-mail de confirmação de compra enviado para ${data.userEmail}:`, result);
    return { success: true, result };
  } catch (error: any) {
    console.error(`[Email Service] Falha ao enviar e-mail de compra para ${data.userEmail}:`, error);
    return { success: false, error: error?.message || "Falha no envio de e-mail" };
  }
}
