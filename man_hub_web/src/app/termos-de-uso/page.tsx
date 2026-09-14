import { Metadata } from "next";
import LegalLayout from "@/components/LegalLayout";
import Link from "next/link";
import { FileText, CheckCircle2, AlertTriangle } from "lucide-react";

export const metadata: Metadata = {
  title: "Termos de Uso | MAN HUB",
  description:
    "Termos e Condições de Uso oficiais do aplicativo MAN HUB e da Interestelar Studios para acesso a treinamentos, armário de looks e recursos premium.",
};

export default function TermosDeUsoPage() {
  return (
    <LegalLayout
      badge="Termos & Condições"
      title="Termos de Uso"
      lastUpdated="14 de Setembro de 2026"
    >
      <div style={{
        background: "rgba(0, 191, 255, 0.08)",
        border: "1px solid rgba(0, 191, 255, 0.25)",
        borderRadius: "12px",
        padding: "16px 20px",
        marginBottom: "28px",
        display: "flex",
        alignItems: "flex-start",
        gap: "12px"
      }}>
        <FileText size={22} color="var(--neon-primary)" style={{ flexShrink: 0, marginTop: "2px" }} />
        <p style={{ margin: 0, fontSize: "14.5px" }}>
          Bem-vindo ao <strong>MAN HUB</strong>. Ao baixar, cadastrar-se ou utilizar o nosso aplicativo e website, você concorda expressamente com os presentes Termos de Uso. Caso não concorde com qualquer disposição aqui estabelecida, recomendamos que não utilize os nossos serviços.
        </p>
      </div>

      <h2>1. Objeto e Definições</h2>
      <p>
        O <strong>MAN HUB</strong> é uma plataforma digital e <strong>Academia de Desenvolvimento Masculino</strong> de titularidade da <strong>Interestelar Studios</strong> (&quot;Interestelar Studios&quot;, &quot;nós&quot; ou &quot;plataforma&quot;), voltada para educação prática, estilo, postura, princípios de alto valor e presença masculina integral.
      </p>
      <p>
        Os serviços compreendem o aplicativo mobile para Android e iOS, o website institucional e todo o ecossistema de trilhas educacionais dinâmicas em formato stories, ferramentas de organização de armário de looks, galeria de cortes de cabelo e recursos interativos.
      </p>

      <h2>2. Elegibilidade e Criação de Conta</h2>
      <p>
        Para usufruir dos recursos completos do MAN HUB, é necessário criar uma conta individual:
      </p>
      <ul>
        <li>O usuário declara ter pelo menos 18 anos ou estar legalmente autorizado por seus responsáveis;</li>
        <li>Você se compromete a fornecer informações verdadeiras, exatas e completas no momento do cadastro;</li>
        <li>A conta é estritamente pessoal e intransferível. Você é o único responsável pela guarda e confidencialidade de sua senha e por todas as atividades realizadas em sua conta;</li>
        <li>Em caso de suspeita de uso indevido ou quebra de segurança de sua conta, notifique-nos imediatamente pelo e-mail <strong>support@interestelar.studio</strong>.</li>
      </ul>

      <h2>3. Propriedade Intelectual e Licença de Uso</h2>
      <p>
        Todos os conteúdos disponibilizados no MAN HUB — incluindo, sem limitação, textos, ilustrações, animações em stories, design de interface, marcas, logotipos, vídeos, arquivos de áudio, códigos-fonte e metodologias pedagógicas — são de propriedade exclusiva da <strong>Interestelar Studios</strong> ou de seus licenciantes e são protegidos pelas leis de propriedade intelectual e direitos autorais.
      </p>
      <p>
        A Interestelar Studios concede ao usuário uma licença pessoal, revogável, não exclusiva e intransferível para acessar e visualizar os conteúdos estritamente para uso pessoal e não comercial.
      </p>
      <div style={{
        background: "rgba(229, 115, 115, 0.08)",
        border: "1px solid rgba(229, 115, 115, 0.3)",
        borderRadius: "12px",
        padding: "16px 20px",
        margin: "20px 0"
      }}>
        <h4 style={{ margin: "0 0 8px", color: "var(--error)", display: "flex", alignItems: "center", gap: "8px" }}>
          <AlertTriangle size={18} />
          Práticas Expressamente Proibidas
        </h4>
        <ul style={{ margin: 0, paddingLeft: "20px", fontSize: "14px" }}>
          <li>Copiar, redistribuir, gravar, transmitir ou sublicenciar os cursos e materiais do aplicativo;</li>
          <li>Compartilhar credenciais de acesso para uso coletivo ou revenda não autorizada;</li>
          <li>Praticar engenharia reversa, descompilação ou tentativa de extração do código-fonte do app;</li>
          <li>Fazer uso de robôs, scrapers ou métodos automatizados para extrair dados da plataforma.</li>
        </ul>
      </div>

      <h2>4. Planos, Pagamentos e Cancelamento</h2>
      <p>
        O MAN HUB oferece modalidades de acesso gratuitas e modalidades pagas:
      </p>
      <ul>
        <li>
          <strong>Treinamentos Individuais (Acesso Vitalício):</strong> Mediante pagamento único, o usuário adquire acesso vitalício ao treinamento específico contratado, incluindo futuras atualizações curriculares daquele treinamento.
        </li>
        <li>
          <strong>Man Hub Pass (Assinatura Recorrente):</strong> Plano de assinatura mensal que concede acesso irrestrito a todos os cursos atuais e futuros enquanto a assinatura permanecer ativa.
        </li>
      </ul>
      <p>
        <strong>Cobranças e Renovações:</strong> Para o plano de assinatura, a cobrança é processada de forma recorrente e automática ao término de cada ciclo (mensal), a menos que o usuário cancele a renovação com pelo menos 24 horas de antecedência ao vencimento.
      </p>
      <p>
        <strong>Direito de Arrependimento e Reembolso:</strong> Em conformidade com o Artigo 49 do Código de Defesa do Consumidor (Lei nº 8.078/1990), o usuário pode solicitar o cancelamento e reembolso integral do valor pago em até <strong>7 (sete) dias corridos</strong> após a contratação. Para compras realizadas pela Google Play Store ou Apple App Store, os pedidos de reembolso devem ser submetidos diretamente à loja respectiva conforme suas diretrizes de cobrança.
      </p>

      <h2>5. Conteúdo Gerado pelo Usuário</h2>
      <p>
        Ao cadastrar peças no armário virtual ou salvar estilos pessoais de corte e looks, o usuário mantém os direitos sobre os conteúdos que inserir, garantindo que não viola direitos de terceiros ou leis vigentes. É terminantemente proibido o envio de imagens ou textos com conteúdo pornográfico, violento, difamatório ou ilegal.
      </p>

      <h2>6. Encerramento e Exclusão de Conta</h2>
      <p>
        Você pode encerrar sua conta a qualquer momento diretamente pelo aplicativo no menu <em>Perfil &gt; Gerenciamento de Conta</em> ou por meio da nossa página de solicitação web em{" "}
        <Link href="/exclusao-de-conta" style={{ color: "var(--neon-primary)", fontWeight: 600 }}>
          manhub.app/exclusao-de-conta
        </Link>.
      </p>
      <p>
        A Interestelar Studios reserva-se o direito de suspender ou cancelar o acesso de qualquer usuário que descumpra estes Termos de Uso ou pratique fraudes contra o ecossistema da plataforma.
      </p>

      <h2>7. Limitação de Responsabilidade</h2>
      <p>
        Os conteúdos disponibilizados no MAN HUB possuem finalidade educativa e de aprimoramento pessoal. Embora nossos materiais sejam fundamentados em boas práticas de etiqueta, caimento, estilo e liderança, a aplicação dos conhecimentos e os resultados dependem exclusivamente do empenho e da conduta individual de cada usuário.
      </p>

      <h2>8. Legislação Aplicável e Foro</h2>
      <p>
        Estes Termos de Uso são regidos e interpretados em conformidade com as leis da República Federativa do Brasil. Para a resolução de qualquer controvérsia decorrente deste contrato, fica eleito o Foro da Comarca de domicílio do usuário consumidor.
      </p>

      <h2>9. Contato e Suporte</h2>
      <p>
        Para dúvidas sobre os Termos de Uso, suporte técnico ou questões contratuais, entre em contato:
      </p>
      <div style={{
        marginTop: "32px",
        padding: "24px",
        background: "rgba(6, 17, 34, 0.8)",
        border: "1px solid var(--card-border)",
        borderRadius: "14px",
        textAlign: "center"
      }}>
        <p style={{ margin: "0 0 8px", fontWeight: 700, color: "#FFFFFF" }}>
          Interestelar Studios — Suporte ao Usuário
        </p>
        <p style={{ margin: "0 0 8px" }}>
          E-mail:{" "}
          <a href="mailto:support@interestelar.studio" style={{ color: "var(--neon-primary)", fontWeight: 600 }}>
            support@interestelar.studio
          </a>
        </p>
        <p style={{ margin: 0, fontSize: "13px", color: "var(--text-muted)" }}>
          Website Oficial:{" "}
          <a href="https://interestelar.studio" target="_blank" rel="noopener noreferrer">
            interestelar.studio
          </a>
        </p>
      </div>
    </LegalLayout>
  );
}
