import { Metadata } from "next";
import LegalLayout from "@/components/LegalLayout";
import Link from "next/link";
import { ShieldCheck, Lock, UserX, Info } from "lucide-react";

export const metadata: Metadata = {
  title: "Política de Privacidade | MAN HUB",
  description:
    "Política de Privacidade oficial do aplicativo MAN HUB e da Interestelar Studios, em total conformidade com a LGPD e diretrizes da Google Play Store.",
};

export default function PoliticaDePrivacidadePage() {
  return (
    <LegalLayout
      badge="Privacidade & Segurança"
      title="Política de Privacidade"
      lastUpdated="14 de Setembro de 2026"
    >
      <div className="alert-box" style={{
        background: "rgba(0, 191, 255, 0.08)",
        border: "1px solid rgba(0, 191, 255, 0.25)",
        borderRadius: "12px",
        padding: "16px 20px",
        marginBottom: "28px",
        display: "flex",
        alignItems: "flex-start",
        gap: "12px"
      }}>
        <ShieldCheck size={22} color="var(--neon-primary)" style={{ flexShrink: 0, marginTop: "2px" }} />
        <p style={{ margin: 0, fontSize: "14.5px" }}>
          Esta Política de Privacidade descreve como a <strong>Interestelar Studios</strong> coleta, usa, armazena e protege os dados pessoais dos usuários do aplicativo <strong>MAN HUB</strong> e do website oficial, em conformidade com a Lei Geral de Proteção de Dados Pessoais (LGPD - Lei nº 13.709/2018) e as diretrizes de segurança da Google Play Store e Apple App Store.
        </p>
      </div>

      <h2>1. Informações Gerais e Controlador de Dados</h2>
      <p>
        O aplicativo <strong>MAN HUB</strong> é desenvolvido e operado pela <strong>Interestelar Studios</strong> (&quot;nós&quot;, &quot;nosso&quot; ou &quot;controlador&quot;). Nosso compromisso é respeitar a sua privacidade e garantir a máxima confidencialidade sobre qualquer informação que você compartilhe conosco.
      </p>
      <p>
        Para qualquer dúvida ou solicitação relacionada a esta política ou ao tratamento de seus dados pessoais, você pode entrar em contato diretamente com o nosso Encarregado de Proteção de Dados através do e-mail: <strong>support@interestelar.studio</strong>.
      </p>

      <h2>2. Dados Pessoais Coletados</h2>
      <p>
        Coletamos apenas os dados estritamente necessários para viabilizar e aprimorar a sua experiência na nossa Academia de Desenvolvimento Masculino:
      </p>
      <ul>
        <li>
          <strong>Dados de Cadastro e Autenticação:</strong> Nome, endereço de e-mail, foto de perfil (quando fornecida) e senha criptografada via serviço Firebase Authentication. Caso opte por login com conta Google ou Apple, recebemos o identificador único fornecido pelo provedor e o e-mail associado.
        </li>
        <li>
          <strong>Dados de Conteúdo e Uso Pessoal:</strong> Looks e peças cadastradas no armário virtual, imagens de cortes de cabelo selecionadas ou enviadas, histórico de aulas e módulos concluídos, telas salvas como favoritos e notas de estilo.
        </li>
        <li>
          <strong>Dados de Transação e Assinatura:</strong> Informações de compra (como plano assinado, data e status do pagamento). <em>Observação importante:</em> dados sensíveis de cartão de crédito são processados diretamente por processadores de pagamento certificados (Mercado Pago, Google Play Billing e Apple In-App Purchase); o MAN HUB <strong>não armazena</strong> números completos de cartões de crédito.
        </li>
        <li>
          <strong>Dados Técnicos e de Dispositivo:</strong> Modelo do aparelho celular, sistema operacional, versão do aplicativo, idioma, relatórios de falhas anônimos (via Firebase Crashlytics) e estatísticas de uso agregadas (via Firebase Analytics).
        </li>
      </ul>

      <h2>3. Finalidade do Tratamento dos Dados</h2>
      <p>Utilizamos os seus dados pessoais com as seguintes finalidades legítimas:</p>
      <ol>
        <li>Prover acesso seguro e autenticado às funcionalidades do aplicativo;</li>
        <li>Sincronizar seu progresso de aulas, telas salvas e armário virtual na nuvem entre sessões;</li>
        <li>Processar a ativação de cursos avulsos ou assinaturas premium;</li>
        <li>Fornecer suporte técnico ao usuário e responder a dúvidas ou solicitações;</li>
        <li>Prevenir fraudes, garantir a segurança dos nossos servidores e cumprir obrigações legais;</li>
        <li>Melhorar continuamente a usabilidade e desempenho do aplicativo.</li>
      </ol>

      <h2>4. Compartilhamento de Dados com Terceiros</h2>
      <p>
        A Interestelar Studios <strong>não comercializa nem aluga dados pessoais de seus usuários</strong> em hipótese alguma. Seus dados são compartilhados estritamente com provedores de infraestrutura essenciais para a operação do serviço:
      </p>
      <ul>
        <li>
          <strong>Google Cloud Platform / Firebase:</strong> Hospedagem de banco de dados (Cloud Firestore), armazenamento em nuvem (Firebase Storage), autenticação (Firebase Auth) e telemetria anônima (Crashlytics).
        </li>
        <li>
          <strong>Mercado Pago / Gateways de Pagamento:</strong> Processamento seguro de pagamentos e prevenção a transações fraudulentas.
        </li>
      </ul>
      <p>
        Todos os parceiros seguem padrões rigorosos de segurança e proteção de dados equivalentes às exigências da LGPD e regulamentos internacionais.
      </p>

      <h2>5. Armazenamento, Segurança e Retenção</h2>
      <p>
        Empregamos medidas técnicas e organizacionais de ponta para proteger seus dados contra acessos não autorizados, perda ou alteração:
      </p>
      <ul>
        <li>Criptografia em trânsito via protocolo HTTPS / TLS de alta intensidade;</li>
        <li>Criptografia de dados em repouso nos servidores do Google Cloud;</li>
        <li>Controle rigoroso de regras de segurança no Firestore e Storage, impedindo que outros usuários acessem seus dados privados;</li>
      </ul>
      <p>
        Os dados são mantidos enquanto sua conta estiver ativa. Caso decida encerrar sua conta, os dados serão excluídos definitivamente conforme descrito a seguir.
      </p>

      <h2>6. Seus Direitos e Exclusão de Conta (LGPD)</h2>
      <p>
        Como titular dos dados, você possui direitos assegurados pelo Artigo 18 da LGPD, incluindo: confirmação de tratamento, acesso aos dados, correção de dados incompletos ou inexatos, anonimização, bloqueio ou eliminação de dados desnecessários e revogação do consentimento.
      </p>

      <div style={{
        background: "rgba(229, 169, 60, 0.08)",
        border: "1px solid rgba(229, 169, 60, 0.3)",
        borderRadius: "12px",
        padding: "20px",
        margin: "24px 0"
      }}>
        <h3 style={{ margin: "0 0 10px", display: "flex", alignItems: "center", gap: "8px", color: "var(--gold-accent)" }}>
          <UserX size={18} />
          Como solicitar a Exclusão Permanente da sua Conta e Dados
        </h3>
        <p style={{ margin: "0 0 12px", fontSize: "14px" }}>
          Você tem total liberdade para excluir sua conta a qualquer momento de duas formas:
        </p>
        <ul style={{ margin: "0 0 12px 20px", fontSize: "14px" }}>
          <li>
            <strong>Direto pelo App:</strong> Abra o MAN HUB &gt; aba <em>Perfil</em> &gt; <em>Gerenciamento de Conta</em> &gt; <em>Excluir Conta Permanentemente</em>.
          </li>
          <li>
            <strong>Pela Página Web Oficial:</strong> Acesse a nossa página dedicada de solicitação em:{" "}
            <Link href="/exclusao-de-conta" style={{ color: "var(--neon-primary)", fontWeight: 600 }}>
              manhub.app/exclusao-de-conta
            </Link>.
          </li>
        </ul>
        <p style={{ margin: 0, fontSize: "13.5px", color: "var(--text-muted)" }}>
          A exclusão é irreversível e remove seu cadastro, credenciais de acesso, fotos enviadas, progresso de aulas e telas salvas.
        </p>
      </div>

      <h2>7. Privacidade de Menores de Idade</h2>
      <p>
        O aplicativo MAN HUB é voltado para o desenvolvimento pessoal, profissional e estilo masculino adulto e não é direcionado a menores de 13 anos. Não coletamos intencionalmente dados de crianças. Caso identifiquemos que uma conta foi criada por um menor sem o devido consentimento dos pais ou responsáveis, a conta e os dados serão prontamente eliminados.
      </p>

      <h2>8. Alterações nesta Política</h2>
      <p>
        Podemos atualizar esta Política de Privacidade periodicamente para refletir melhorias no serviço ou mudanças na legislação aplicável. A versão revisada será sempre publicada nesta página com a data da última atualização.
      </p>

      <h2>9. Canal de Contato</h2>
      <p>
        Se você tiver qualquer pergunta, preocupação ou desejar exercer seus direitos como titular de dados, fale com nosso time de privacidade:
      </p>
      <div style={{
        marginTop: "40px",
        padding: "24px",
        background: "rgba(6, 17, 34, 0.8)",
        border: "1px solid var(--card-border)",
        borderRadius: "14px",
        textAlign: "center"
      }}>
        <p style={{ margin: "0 0 8px", fontWeight: 700, color: "#FFFFFF" }}>
          Interestelar Studios — Equipe de Privacidade & DPO
        </p>
        <p style={{ margin: "0 0 8px" }}>
          E-mail direto:{" "}
          <a href="mailto:support@interestelar.studio" style={{ color: "var(--neon-primary)", fontWeight: 600 }}>
            support@interestelar.studio
          </a>
        </p>
        <p style={{ margin: 0, fontSize: "13px", color: "var(--text-muted)" }}>
          Website Institucional:{" "}
          <a href="https://interestelar.studio" target="_blank" rel="noopener noreferrer">
            interestelar.studio
          </a>
        </p>
      </div>
    </LegalLayout>
  );
}
