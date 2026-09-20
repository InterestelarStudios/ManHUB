export interface WelcomeEmailData {
  userName?: string;
  userEmail: string;
  appUrl?: string;
}

export interface PurchaseConfirmationEmailData {
  userName?: string;
  userEmail: string;
  itemName: string;
  itemType: "pass" | "training";
  amount: number;
  paymentId?: string;
  appUrl?: string;
}

/**
 * Template de E-mail de Boas-Vindas após criação de conta
 */
export function getWelcomeEmailHtml({ userName, userEmail, appUrl = "https://manhub.app" }: WelcomeEmailData): string {
  const name = userName ? userName.split(" ")[0] : "Membro";

  return `
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bem-vindo ao MAN HUB</title>
</head>
<body style="margin: 0; padding: 0; background-color: #040D1A; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: #FFFFFF;">
  <table border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; background-color: #040D1A; padding: 30px 15px;">
    <tr>
      <td align="center">
        <!-- Container Principal -->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 580px; background-color: #061224; border: 1px solid rgba(0, 191, 255, 0.25); border-radius: 16px; overflow: hidden; box-shadow: 0 15px 40px rgba(0,0,0,0.6);">
          
          <!-- Top Accent Bar -->
          <tr>
            <td height="4" style="background: linear-gradient(90deg, #00BFFF 0%, #1E90FF 50%, #E5A93C 100%);"></td>
          </tr>

          <!-- Header com Logo -->
          <tr>
            <td align="center" style="padding: 36px 24px 20px;">
              <img src="https://manhub.app/manhub_icon.png" alt="MAN HUB Logo" width="52" height="52" style="display: block; margin-bottom: 12px; border-radius: 12px;" />
              <h2 style="margin: 0; font-size: 22px; font-weight: 800; letter-spacing: 0.1em; color: #FFFFFF;">MAN HUB</h2>
              <p style="margin: 4px 0 0; font-size: 11px; text-transform: uppercase; letter-spacing: 0.2em; color: #00BFFF; font-weight: 600;">Evolução Masculina</p>
            </td>
          </tr>

          <!-- Divisor Sutil -->
          <tr>
            <td style="padding: 0 32px;">
              <div style="height: 1px; background-color: rgba(255, 255, 255, 0.08);"></div>
            </td>
          </tr>

          <!-- Conteúdo do E-mail -->
          <tr>
            <td style="padding: 32px 36px;">
              <span style="display: inline-block; background-color: rgba(0, 191, 255, 0.12); color: #00BFFF; border: 1px solid rgba(0, 191, 255, 0.3); padding: 4px 12px; border-radius: 50px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 16px;">
                Conta Criada com Sucesso
              </span>

              <h1 style="margin: 0 0 16px; font-size: 24px; font-weight: 800; color: #FFFFFF; line-height: 1.3;">
                Bem-vindo à sua jornada de evolução, ${name}!
              </h1>

              <p style="margin: 0 0 18px; font-size: 15px; line-height: 1.6; color: #B0BEC5;">
                A imagem é apenas o começo. A partir de agora, você faz parte de um ecossistema desenvolvido para homens contemporâneos que buscam autoridade, estilo magnético e desenvolvimento pessoal consistente.
              </p>

              <!-- Box de Destaques -->
              <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: rgba(4, 13, 26, 0.6); border: 1px solid rgba(0, 191, 255, 0.15); border-radius: 12px; margin: 20px 0 28px;">
                <tr>
                  <td style="padding: 20px;">
                    <p style="margin: 0 0 12px; font-size: 14px; font-weight: 700; color: #00BFFF;">
                      O que você tem acesso agora:
                    </p>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td width="24" valign="top" style="color: #00BFFF; font-size: 14px; line-height: 1.6;">✔</td>
                        <td style="font-size: 13.5px; color: #CFD8DC; line-height: 1.6; padding-bottom: 8px;">
                          <strong>1º Módulo Gratuito:</strong> Experimente as primeiras aulas de todos os treinamentos oficiais sem custo.
                        </td>
                      </tr>
                      <tr>
                        <td width="24" valign="top" style="color: #00BFFF; font-size: 14px; line-height: 1.6;">✔</td>
                        <td style="font-size: 13.5px; color: #CFD8DC; line-height: 1.6; padding-bottom: 8px;">
                          <strong>Aulas em Formato Stories:</strong> Conteúdo ágil, prático e visual de 20 a 40 segundos.
                        </td>
                      </tr>
                      <tr>
                        <td width="24" valign="top" style="color: #00BFFF; font-size: 14px; line-height: 1.6;">✔</td>
                        <td style="font-size: 13.5px; color: #CFD8DC; line-height: 1.6;">
                          <strong>Sincronização Total:</strong> Seu progresso é salvo e sincronizado na web e no app mobile.
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>

              <!-- CTA Button -->
              <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td align="center">
                    <a href="${appUrl}/treinamentos" target="_blank" style="display: inline-block; background: linear-gradient(135deg, #00BFFF 0%, #005F9E 100%); color: #FFFFFF; text-decoration: none; font-size: 15px; font-weight: 700; padding: 15px 36px; border-radius: 50px; box-shadow: 0 4px 20px rgba(0, 191, 255, 0.4); text-align: center;">
                      Explorar Treinamentos
                    </a>
                  </td>
                </tr>
              </table>

              <p style="margin: 28px 0 0; font-size: 13px; color: #8A9AAB; line-height: 1.5; text-align: center;">
                Sua conta está associada ao e-mail: <strong style="color: #FFFFFF;">${userEmail}</strong>
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #040D1A; padding: 24px; text-align: center; border-top: 1px solid rgba(255, 255, 255, 0.05);">
              <p style="margin: 0; font-size: 12px; color: #546E7A; line-height: 1.5;">
                © 2026 MAN HUB • Academia de Desenvolvimento Masculino.<br />
                Desenvolvido por Interestelar Studios.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `;
}

/**
 * Template de E-mail de Confirmação e Agradecimento de Compra
 */
export function getPurchaseConfirmationEmailHtml({
  userName,
  userEmail,
  itemName,
  itemType,
  amount,
  paymentId,
  appUrl = "https://manhub.app",
}: PurchaseConfirmationEmailData): string {
  const name = userName ? userName.split(" ")[0] : "Membro";
  const formattedAmount = `R$ ${amount.toFixed(2).replace(".", ",")}`;
  const isSubscription = itemType === "pass";

  return `
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Compra Confirmada - MAN HUB</title>
</head>
<body style="margin: 0; padding: 0; background-color: #040D1A; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: #FFFFFF;">
  <table border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; background-color: #040D1A; padding: 30px 15px;">
    <tr>
      <td align="center">
        <!-- Container Principal -->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 580px; background-color: #061224; border: 1px solid rgba(0, 191, 255, 0.25); border-radius: 16px; overflow: hidden; box-shadow: 0 15px 40px rgba(0,0,0,0.6);">
          
          <!-- Top Accent Bar -->
          <tr>
            <td height="4" style="background: linear-gradient(90deg, #00BFFF 0%, #1E90FF 50%, #4CAF50 100%);"></td>
          </tr>

          <!-- Header com Logo -->
          <tr>
            <td align="center" style="padding: 36px 24px 20px;">
              <img src="https://manhub.app/manhub_icon.png" alt="MAN HUB Logo" width="52" height="52" style="display: block; margin-bottom: 12px; border-radius: 12px;" />
              <h2 style="margin: 0; font-size: 22px; font-weight: 800; letter-spacing: 0.1em; color: #FFFFFF;">MAN HUB</h2>
              <p style="margin: 4px 0 0; font-size: 11px; text-transform: uppercase; letter-spacing: 0.2em; color: #00BFFF; font-weight: 600;">Evolução Masculina</p>
            </td>
          </tr>

          <!-- Divisor Sutil -->
          <tr>
            <td style="padding: 0 32px;">
              <div style="height: 1px; background-color: rgba(255, 255, 255, 0.08);"></div>
            </td>
          </tr>

          <!-- Conteúdo do E-mail -->
          <tr>
            <td style="padding: 32px 36px;">
              
              <!-- Badge de Status -->
              <span style="display: inline-block; background-color: rgba(76, 175, 80, 0.15); color: #81C784; border: 1px solid rgba(76, 175, 80, 0.4); padding: 4px 12px; border-radius: 50px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 16px;">
                ✔ Pagamento Aprovado
              </span>

              <h1 style="margin: 0 0 14px; font-size: 24px; font-weight: 800; color: #FFFFFF; line-height: 1.3;">
                Muito obrigado pela confiança, ${name}!
              </h1>

              <p style="margin: 0 0 20px; font-size: 15px; line-height: 1.6; color: #B0BEC5;">
                Seu acesso foi liberado com sucesso. Você acaba de investir na ferramenta que transformará sua imagem, confiança e postura profissional.
              </p>

              <!-- Box de Detalhes da Compra -->
              <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: rgba(4, 13, 26, 0.8); border: 1px solid rgba(0, 191, 255, 0.25); border-radius: 12px; margin: 0 0 26px;">
                <tr>
                  <td style="padding: 22px;">
                    <p style="margin: 0 0 6px; font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em; color: #8A9AAB;">
                      ${isSubscription ? "Plano de Assinatura" : "Treinamento Desbloqueado"}
                    </p>
                    <h3 style="margin: 0 0 14px; font-size: 18px; color: #FFFFFF; font-weight: 700;">
                      ${itemName}
                    </h3>
                    
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td style="font-size: 13.5px; color: #90A4AE; padding: 4px 0;">Valor Pago:</td>
                        <td align="right" style="font-size: 15px; color: #00BFFF; font-weight: 800; padding: 4px 0;">
                          ${formattedAmount} ${isSubscription ? "/ mês" : "vitalício"}
                        </td>
                      </tr>
                      <tr>
                        <td style="font-size: 13.5px; color: #90A4AE; padding: 4px 0;">Acesso Vinculado a:</td>
                        <td align="right" style="font-size: 13.5px; color: #FFFFFF; font-weight: 600; padding: 4px 0;">
                          ${userEmail}
                        </td>
                      </tr>
                      ${
                        paymentId
                          ? `<tr>
                        <td style="font-size: 12px; color: #607D8B; padding: 4px 0;">ID da Transação:</td>
                        <td align="right" style="font-size: 12px; color: #8A9AAB; padding: 4px 0;">
                          #${paymentId}
                        </td>
                      </tr>`
                          : ""
                      }
                    </table>
                  </td>
                </tr>
              </table>

              <!-- Como Acessar -->
              <h3 style="margin: 0 0 12px; font-size: 16px; color: #FFFFFF;">
                Como acessar seu conteúdo agora:
              </h3>
              
              <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-bottom: 26px;">
                <tr>
                  <td width="28" valign="top" style="color: #00BFFF; font-weight: 800; font-size: 15px; line-height: 1.5;">1.</td>
                  <td style="font-size: 14px; color: #CFD8DC; line-height: 1.5; padding-bottom: 10px;">
                    Acesse seu painel através do link: <a href="${appUrl}/conta" target="_blank" style="color: #00BFFF; text-decoration: underline;">${appUrl}/conta</a>.
                  </td>
                </tr>
                <tr>
                  <td width="28" valign="top" style="color: #00BFFF; font-weight: 800; font-size: 15px; line-height: 1.5;">2.</td>
                  <td style="font-size: 14px; color: #CFD8DC; line-height: 1.5; padding-bottom: 10px;">
                    Faça login com seu e-mail (<strong>${userEmail}</strong>).
                  </td>
                </tr>
                <tr>
                  <td width="28" valign="top" style="color: #00BFFF; font-weight: 800; font-size: 15px; line-height: 1.5;">3.</td>
                  <td style="font-size: 14px; color: #CFD8DC; line-height: 1.5;">
                    Abra o treinamento e comece imediatamente a assistir às aulas em formato de Stories!
                  </td>
                </tr>
              </table>

              <!-- CTA Button -->
              <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td align="center">
                    <a href="${appUrl}/conta" target="_blank" style="display: inline-block; background: linear-gradient(135deg, #00BFFF 0%, #005F9E 100%); color: #FFFFFF; text-decoration: none; font-size: 15px; font-weight: 700; padding: 15px 36px; border-radius: 50px; box-shadow: 0 4px 20px rgba(0, 191, 255, 0.4); text-align: center;">
                      Acessar Minha Conta & Aulas
                    </a>
                  </td>
                </tr>
              </table>

            </td>
          </tr>

          <!-- Support Notice -->
          <tr>
            <td style="background-color: #040D1A; padding: 22px 36px; border-top: 1px solid rgba(255, 255, 255, 0.06); text-align: center;">
              <p style="margin: 0; font-size: 12.5px; color: #78909C; line-height: 1.6;">
                Precisa de ajuda ou tem alguma dúvida? Basta responder a este e-mail que nossa equipe estará pronta para te ajudar.
              </p>
              <p style="margin: 12px 0 0; font-size: 11px; color: #455A64;">
                © 2026 MAN HUB • Interestelar Studios
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `;
}
