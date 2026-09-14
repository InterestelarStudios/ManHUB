import { Metadata } from "next";
import LegalLayout from "@/components/LegalLayout";
import AccountDeletionForm from "@/components/AccountDeletionForm";
import { Smartphone, Globe, CheckCircle2, ShieldAlert, Mail } from "lucide-react";

export const metadata: Metadata = {
  title: "Exclusão de Conta e Dados | MAN HUB",
  description:
    "Solicitação de exclusão de conta e remoção de dados pessoais do aplicativo MAN HUB, em conformidade com as diretrizes do Google Play e a LGPD.",
};

export default function ExclusaoDeContaPage() {
  return (
    <LegalLayout
      badge="Direitos do Usuário • LGPD"
      title="Exclusão de Conta e Dados Pessoais"
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
        <ShieldAlert size={22} color="var(--neon-primary)" style={{ flexShrink: 0, marginTop: "2px" }} />
        <p style={{ margin: 0, fontSize: "14.5px" }}>
          Em conformidade com a <strong>Política de Dados do Usuário do Google Play</strong> e a <strong>Lei Geral de Proteção de Dados (LGPD)</strong>, você tem o direito de solicitar a exclusão definitiva de sua conta no <strong>MAN HUB</strong> e de todos os dados pessoais e conteúdos a ela vinculados.
        </p>
      </div>

      <h2>Opção 1: Exclusão Instantânea pelo Aplicativo (Recomendado)</h2>
      <p>
        Se você ainda possui o aplicativo MAN HUB instalado em seu smartphone, a forma mais rápida e imediata de apagar sua conta é pelo próprio app:
      </p>

      <div style={{
        display: "grid",
        gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
        gap: "16px",
        margin: "20px 0 32px"
      }}>
        <div style={{
          background: "rgba(7, 20, 38, 0.8)",
          border: "1px solid var(--card-border)",
          borderRadius: "12px",
          padding: "18px",
        }}>
          <span style={{ fontSize: "12px", color: "var(--neon-primary)", fontWeight: 700, display: "block", marginBottom: "6px" }}>PASSO 1</span>
          <h4 style={{ color: "#FFFFFF", fontSize: "15px", marginBottom: "6px" }}>Abra o Aplicativo</h4>
          <p style={{ fontSize: "13px", color: "var(--text-secondary)", margin: 0 }}>
            Inicie a sessão no app MAN HUB no seu smartphone Android ou iOS.
          </p>
        </div>

        <div style={{
          background: "rgba(7, 20, 38, 0.8)",
          border: "1px solid var(--card-border)",
          borderRadius: "12px",
          padding: "18px",
        }}>
          <span style={{ fontSize: "12px", color: "var(--neon-primary)", fontWeight: 700, display: "block", marginBottom: "6px" }}>PASSO 2</span>
          <h4 style={{ color: "#FFFFFF", fontSize: "15px", marginBottom: "6px" }}>Acesse o Perfil</h4>
          <p style={{ fontSize: "13px", color: "var(--text-secondary)", margin: 0 }}>
            Toque na aba <strong>Perfil</strong> na barra inferior de navegação.
          </p>
        </div>

        <div style={{
          background: "rgba(7, 20, 38, 0.8)",
          border: "1px solid var(--card-border)",
          borderRadius: "12px",
          padding: "18px",
        }}>
          <span style={{ fontSize: "12px", color: "var(--neon-primary)", fontWeight: 700, display: "block", marginBottom: "6px" }}>PASSO 3</span>
          <h4 style={{ color: "#FFFFFF", fontSize: "15px", marginBottom: "6px" }}>Gerenciamento</h4>
          <p style={{ fontSize: "13px", color: "var(--text-secondary)", margin: 0 }}>
            Selecione a opção <strong>Gerenciamento de Conta</strong> na lista de configurações.
          </p>
        </div>

        <div style={{
          background: "rgba(7, 20, 38, 0.8)",
          border: "1px solid var(--card-border)",
          borderRadius: "12px",
          padding: "18px",
        }}>
          <span style={{ fontSize: "12px", color: "var(--error)", fontWeight: 700, display: "block", marginBottom: "6px" }}>PASSO 4</span>
          <h4 style={{ color: "#FFFFFF", fontSize: "15px", marginBottom: "6px" }}>Excluir Conta</h4>
          <p style={{ fontSize: "13px", color: "var(--text-secondary)", margin: 0 }}>
            Toque em <strong>Excluir Conta Permanentemente</strong> e confirme a operação.
          </p>
        </div>
      </div>

      <h2>Opção 2: Solicitar Exclusão via Web (Sem Acesso ao App)</h2>
      <p>
        Caso tenha desinstalado o aplicativo ou perdido o acesso ao dispositivo móvel, utilize o formulário abaixo para registrar formalmente o pedido de exclusão:
      </p>

      {/* Formulário Interativo */}
      <AccountDeletionForm />

      <h2>Quais dados são excluídos permanentemente?</h2>
      <p>
        Ao solicitar a exclusão, os seguintes dados são eliminados definitivamente de nossos servidores:
      </p>
      <ul>
        <li>
          <strong>Credenciais e Autenticação:</strong> Registro de usuário no Firebase Authentication, e-mail e hashes de senha;
        </li>
        <li>
          <strong>Perfil do Usuário:</strong> Nome, foto de perfil, preferências de estilo e histórico de atividades;
        </li>
        <li>
          <strong>Armário Virtual & Looks:</strong> Todas as fotos de roupas, composições e itens salvos no guarda-roupa virtual;
        </li>
        <li>
          <strong>Cortes de Cabelo:</strong> Penteados e estilos favoritados ou enviados;
        </li>
        <li>
          <strong>Progresso nos Cursos:</strong> Aulas assistidas, módulos concluídos e anotações pessoais.
        </li>
      </ul>

      <h2>Quais dados podem ser retidos e por quanto tempo?</h2>
      <p>
        Determinados dados fiscais e de faturamento podem ser retidos exclusivamente para cumprimento de obrigações legais e regulatórias (como exigências da Receita Federal e legislação tributária brasileira relativas a notas fiscais e registros de transações de compra de cursos ou assinaturas), pelo prazo estritamente exigido em lei (geralmente 5 anos). Tais dados são mantidos em ambiente isolado e não são utilizados para nenhuma outra finalidade.
      </p>

      <h2>Prazo de Processamento</h2>
      <ul>
        <li><strong>Exclusão pelo Aplicativo:</strong> Concluída instantaneamente.</li>
        <li><strong>Solicitação via Web ou E-mail:</strong> Processada em até <strong>5 (cinco) dias úteis</strong> pela equipe técnica da Interestelar Studios, com confirmação enviada ao e-mail informado.</li>
      </ul>

      <h2>Dúvidas ou Ajuda?</h2>
      <p>
        Você também pode enviar uma solicitação direta de exclusão através do nosso e-mail de suporte:
      </p>
      <div style={{
        marginTop: "24px",
        padding: "20px",
        background: "rgba(6, 17, 34, 0.8)",
        border: "1px solid var(--card-border)",
        borderRadius: "12px",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        flexWrap: "wrap",
        gap: "16px"
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
          <Mail size={22} color="var(--neon-primary)" />
          <div>
            <span style={{ fontSize: "12px", color: "var(--text-muted)", display: "block" }}>Canal de Privacidade e DPO:</span>
            <span style={{ fontSize: "15px", fontWeight: 600, color: "#FFFFFF" }}>support@interestelar.studio</span>
          </div>
        </div>

        <a
          href="mailto:support@interestelar.studio?subject=Solicita%C3%A7%C3%A3o%20de%20Exclus%C3%A3o%20de%20Conta%20-%20Man%20Hub"
          className="btn btn-secondary"
          style={{ padding: "8px 18px", fontSize: "13px" }}
        >
          Enviar E-mail
        </a>
      </div>
    </LegalLayout>
  );
}
