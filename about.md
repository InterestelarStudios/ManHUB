# MAN HUB

## Documento de Contexto e Especificação do Projeto

## 1. VISÃO GERAL

O **Man Hub** é um aplicativo voltado para o desenvolvimento masculino integral.

A proposta não é criar simplesmente um aplicativo de moda, beleza ou cuidados pessoais. O objetivo é criar um **HUB de evolução masculina**, reunindo em um único lugar conhecimentos, treinamentos, recomendações e ferramentas que ajudem o usuário a desenvolver diferentes aspectos de sua vida.

O conceito central da marca é:

> **A imagem é apenas o começo. A verdadeira transformação acontece de dentro para fora.**

O aplicativo deve ajudar o usuário a evoluir em aspectos como:

* mentalidade;
* disciplina;
* autoconhecimento;
* confiança;
* postura;
* comunicação;
* estilo;
* vestimenta;
* visagismo;
* cabelo;
* barba;
* skincare;
* higiene e autocuidado;
* perfumes;
* corpo e condicionamento;
* presença social;
* imagem profissional;
* desenvolvimento pessoal.

A ideia é que o usuário não entre no aplicativo simplesmente para descobrir qual corte de cabelo combina com ele. Ele deve sentir que está entrando em uma **jornada de transformação pessoal**.

O Man Hub deve transmitir a sensação de:

* evolução;
* sofisticação;
* masculinidade;
* disciplina;
* confiança;
* exclusividade;
* inteligência;
* autocuidado;
* presença.

Não queremos criar uma experiência de "guru", "coach" ou conteúdo de masculinidade tóxica.

O posicionamento deve ser:

**Homens ajudando homens a evoluírem.**

---

# 2. PROPOSTA DE VALOR

O Man Hub pretende resolver um problema simples:

Existem inúmeros conteúdos espalhados sobre moda masculina, academia, perfumes, cabelo, barba, skincare, comportamento e desenvolvimento pessoal, mas normalmente estão separados em diferentes plataformas.

O Man Hub centraliza esses conhecimentos em uma única experiência.

Além disso, o aplicativo deve utilizar o perfil individual do usuário para oferecer recomendações personalizadas.

Exemplo:

Um usuário informa ou permite que a IA identifique:

* formato do rosto;
* características físicas;
* estilo atual;
* objetivos;
* preferências.

O aplicativo pode então recomendar:

* cortes de cabelo;
* estilos de barba;
* combinações de roupas;
* cores;
* acessórios;
* perfumes;
* rotinas de autocuidado;
* treinamentos relevantes.

No futuro, o usuário poderá simplesmente enviar uma foto e a IA poderá auxiliar na identificação dessas características.

---

# 3. PÚBLICO-ALVO

O público principal são homens adultos, principalmente jovens e adultos que desejam melhorar sua imagem e sua vida.

O usuário pode estar buscando:

* melhorar sua aparência;
* melhorar sua confiança;
* começar a se cuidar;
* aprender a se vestir;
* melhorar sua presença;
* melhorar sua vida profissional;
* desenvolver disciplina;
* melhorar sua comunicação;
* construir uma identidade pessoal mais forte;
* tornar-se uma versão melhor de si mesmo.

O aplicativo não deve pressupor que todos os usuários possuem o mesmo objetivo.

Por isso, a personalização é uma parte importante da experiência.

---

# 4. FILOSOFIA DO PRODUTO

A filosofia do Man Hub é baseada em uma ideia:

## "Torne-se um homem de valor."

Porém, "homem de valor" não significa necessariamente:

* ter muito dinheiro;
* ser fisicamente perfeito;
* possuir roupas caras;
* ter muitas mulheres;
* possuir status;
* parecer superior aos outros.

O conceito deve ser baseado em características como:

* caráter;
* responsabilidade;
* disciplina;
* autocontrole;
* respeito próprio;
* cuidado pessoal;
* inteligência;
* capacidade de comunicação;
* postura;
* consistência;
* ambição saudável;
* capacidade de assumir responsabilidades;
* busca constante por evolução.

A aparência é uma ferramenta de expressão e posicionamento, não a definição do valor do indivíduo.

---

# 5. ONBOARDING

O onboarding deve apresentar o Man Hub como uma jornada de transformação.

### Tela 1

Mensagem:

**"Mais do que estilo. Uma nova versão de você."**

Explicação de que o Man Hub trabalha evolução de dentro para fora.

### Tela 2

Mensagem:

**"Domine sua imagem. Comande sua presença."**

Mostrar que estilo, aparência e postura fazem parte da forma como o usuário se apresenta ao mundo.

### Tela 3

Mensagem:

**"Corpo, mente e propósito em equilíbrio."**

Apresentar os diferentes pilares do aplicativo.

### Tela 4

Mensagem:

**"Sua transformação começa agora."**

CTA:

**"Começar minha jornada"**

Depois disso o usuário deve seguir para cadastro/autenticação.

---

# 6. AUTENTICAÇÃO

O aplicativo deverá permitir:

* cadastro por e-mail;
* login por e-mail;
* Google;
* Apple no iOS;
* recuperação de senha;
* logout.

A autenticação deverá utilizar Firebase Authentication.

---

# 7. QUESTIONÁRIO INICIAL

Após criar a conta, o usuário deverá realizar um onboarding personalizado.

O objetivo é conhecer o usuário.

Informações possíveis:

### Informações básicas

* nome;
* idade;
* altura;
* peso.

### Características físicas

* tipo físico;
* formato de rosto;
* tom de pele;
* características relevantes para recomendações.

### Estilo

* estilo atual;
* estilos desejados;
* preferências de vestimenta;
* frequência com que se preocupa com aparência.

### Objetivos

O usuário poderá selecionar objetivos como:

* melhorar estilo;
* melhorar aparência;
* melhorar confiança;
* melhorar postura;
* cuidar melhor do corpo;
* melhorar comunicação;
* desenvolver disciplina;
* melhorar imagem profissional;
* aprender sobre perfumes;
* melhorar skincare;
* desenvolver-se de maneira geral.

O questionário deve ser dividido em etapas para não parecer cansativo.

Ao final, mostrar um resumo do perfil.

CTA:

**"Criar meu plano de evolução"**

---

# 8. INTELIGÊNCIA ARTIFICIAL

A IA será uma funcionalidade importante do projeto, mas não precisa estar completamente implementada no primeiro MVP.

Futuramente, o usuário poderá enviar uma fotografia.

A IA poderá auxiliar na identificação de características visuais como:

* formato aproximado do rosto;
* características relacionadas ao cabelo;
* características relevantes para visagismo;
* possíveis recomendações de estilo;
* outras informações visualmente inferíveis.

O sistema deverá deixar claro que análises visuais são estimativas e recomendações, não diagnósticos.

A IA também poderá funcionar como um **consultor pessoal de estilo e desenvolvimento**.

Exemplos de perguntas:

"Qual corte combina com meu rosto?"

"Qual perfume devo usar hoje?"

"Como posso melhorar esse look?"

"Quais peças básicas deveria ter?"

"Como montar uma rotina simples de skincare?"

"Qual treinamento devo fazer primeiro?"

A IA deve utilizar os dados do perfil do usuário para contextualizar as respostas.

---

# 9. HOME / DASHBOARD

A Home será o centro do aplicativo.

Ela deve apresentar uma experiência personalizada.

Elementos possíveis:

### Saudação

"Boa noite, Walker."

### Progresso

Mostrar evolução do usuário.

Exemplo:

**Jornada do Homem de Valor**
45% concluída.

### Continue de onde parou

Mostrar o treinamento/aula atual.

### Recomendação do dia

Uma recomendação personalizada.

### Seu próximo passo

Mostrar uma ação simples para o usuário realizar.

### Categorias

Acesso rápido para:

* Jornada;
* Estilo;
* Visagismo;
* Perfumes;
* Skincare;
* Corpo;
* Comunicação;
* Shopping.

### Novidades

Mostrar novos treinamentos e conteúdos.

A Home não deve ficar visualmente sobrecarregada.

---

# 10. TREINAMENTO PRINCIPAL

O treinamento principal será:

# "A Jornada do Homem de Valor"

Ele representa o núcleo conceitual do Man Hub.

A jornada será dividida em módulos.

## Módulo 1 — Mentalidade do Homem de Valor

Conteúdos:

* o que é um homem de valor;
* responsabilidade pessoal;
* autodisciplina;
* comportamentos que enfraquecem;
* respeito próprio;
* postura interna;
* construção de um código pessoal.

## Módulo 2 — Autoconhecimento e Identidade

Conteúdos:

* descobrir quem você é;
* identificar forças e fraquezas;
* objetivos;
* identidade;
* personalidade;
* estilo como extensão da personalidade.

## Módulo 3 — Corpo, Postura e Presença

Conteúdos:

* postura;
* linguagem corporal;
* caminhada;
* presença;
* contato visual;
* consciência corporal;
* exercícios básicos relacionados à postura.

## Módulo 4 — Estilo Masculino Inteligente

Conteúdos:

* fundamentos do estilo;
* proporções;
* tipos físicos;
* roupas;
* combinações;
* guarda-roupa;
* erros comuns;
* como se vestir de acordo com diferentes situações.

## Módulo 5 — Visagismo: Cabelo e Barba

Conteúdos:

* formatos de rosto;
* cortes;
* barba;
* proporção facial;
* manutenção;
* harmonia visual.

## Módulo 6 — Cuidado Pessoal e Autodisciplina

Conteúdos:

* higiene;
* skincare;
* cabelo;
* barba;
* unhas;
* rotina;
* organização;
* consistência.

## Módulo 7 — Perfume, Presença e Memória

Conteúdos:

* famílias olfativas;
* ocasiões;
* aplicação;
* duração;
* projeção;
* assinatura olfativa.

## Módulo 8 — Comunicação e Confiança

Conteúdos:

* comunicação verbal;
* linguagem corporal;
* voz;
* contato visual;
* controle emocional;
* posicionamento.

## Módulo 9 — Posicionamento Social e Profissional

Conteúdos:

* imagem profissional;
* comportamento;
* networking;
* presença;
* coerência entre imagem e comportamento.

## Módulo 10 — Seu Código de Valor

Conteúdos:

* consolidação;
* princípios;
* hábitos;
* consistência;
* manutenção;
* evolução contínua.

---

# 11. ESTRUTURA DOS TREINAMENTOS

Cada treinamento poderá conter:

* capa;
* descrição;
* objetivos;
* módulos;
* aulas;
* vídeos;
* textos;
* imagens;
* exercícios;
* checklists;
* quizzes;
* progresso.

O progresso deve ser salvo individualmente.

O usuário deve conseguir continuar exatamente de onde parou.

---

# 12. TREINAMENTOS FUTUROS

Além da Jornada do Homem de Valor, poderão existir treinamentos independentes.

Exemplos:

* Estilo Masculino Avançado;
* Guarda-Roupa Inteligente;
* Perfumes Masculinos;
* Perfumes de Nicho;
* Visagismo Avançado;
* Skincare Masculino;
* Treino em Casa;
* Comunicação e Oratória;
* Imagem Profissional;
* Estilo Minimalista;
* Como se vestir bem gastando pouco;
* Guia de acessórios;
* Guia de relógios;
* Linguagem corporal;
* Desenvolvimento de confiança.

Esses treinamentos poderão ser vendidos separadamente.

---

# 13. SISTEMA DE PROGRESSO

O usuário deve ter uma área de progresso.

Mostrar:

* treinamentos iniciados;
* treinamentos concluídos;
* aulas concluídas;
* porcentagem de progresso;
* conquistas;
* sequência de atividades;
* próximos passos.

No futuro, pode existir um sistema de níveis.

Exemplo:

**Nível 1 — Fundamentos**

**Nível 2 — Evolução**

**Nível 3 — Presença**

**Nível 4 — Domínio**

Isso não precisa estar no primeiro MVP.

---

# 14. RECOMENDAÇÕES PERSONALIZADAS

Uma das principais funcionalidades do aplicativo.

O sistema deverá utilizar os dados do usuário para gerar recomendações.

Exemplos:

### Rosto

"Seu formato de rosto combina melhor com determinados estilos de corte."

### Estilo

"Considerando seu objetivo e estilo atual, estas peças podem fazer parte do seu guarda-roupa."

### Perfume

"Para uma ocasião noturna, estas famílias olfativas podem ser interessantes."

### Autocuidado

"Você ainda não concluiu seu treinamento de skincare."

### Evolução

"Seu próximo treinamento recomendado é Comunicação e Confiança."

As recomendações devem parecer parte de um plano pessoal, e não simplesmente uma lista genérica.

---

# 15. SHOPPING

O Man Hub terá uma área de produtos masculinos.

Categorias:

* perfumes;
* roupas;
* calçados;
* relógios;
* acessórios;
* skincare;
* cabelo;
* barba;
* produtos de autocuidado;
* produtos relacionados a treino.

O aplicativo não necessariamente venderá os produtos diretamente.

Inicialmente poderá utilizar:

* links de afiliados;
* cupons;
* parcerias comerciais.

Ao clicar em um produto, o usuário poderá ser direcionado ao parceiro externo.

Cada produto poderá possuir:

* imagem;
* nome;
* descrição;
* categoria;
* faixa de preço;
* motivo da recomendação;
* link;
* cupom;
* marca;
* tags.

---

# 16. MONETIZAÇÃO

O modelo inicial será baseado em uma compra de acesso vitalício.

O usuário cria a conta e posteriormente encontra uma tela de:

**"Desbloqueie sua jornada completa."**

A compra libera o conteúdo principal.

Além disso, poderão existir treinamentos adicionais vendidos separadamente.

Modelo:

### Acesso Vitalício

Desbloqueia:

* Jornada do Homem de Valor;
* conteúdos fundamentais;
* recomendações;
* recursos disponíveis no plano.

### Extensões Premium

Novos treinamentos poderão ser adquiridos individualmente.

### Shopping

Monetização através de:

* afiliados;
* cupons;
* parcerias.

---

# 17. PERFIL

A tela de perfil deverá mostrar:

* foto;
* nome;
* informações pessoais;
* características físicas;
* estilo;
* objetivos;
* progresso;
* treinamentos adquiridos.

O usuário poderá editar suas informações.

---

# 18. CONFIGURAÇÕES

Deverá existir uma área de configurações contendo:

* conta;
* notificações;
* privacidade;
* idioma;
* suporte;
* termos;
* política de privacidade;
* gerenciamento de acesso;
* logout.

---

# 19. NAVEGAÇÃO PRINCIPAL

Uma possível navegação inferior:

### Home

Dashboard personalizado.

### Jornada

Treinamentos e progresso.

### Estilo

Recomendações de imagem e autocuidado.

### Shopping

Produtos recomendados.

### Perfil

Dados, progresso e configurações.

A estrutura pode ser ajustada caso outra solução ofereça uma UX melhor.

---

# 20. IDENTIDADE VISUAL

A identidade visual foi inspirada nos tons do perfume fornecido como referência.

O conceito visual é:

**Night / Luxury / Masculine / Neon / Technology**

A interface deve utilizar predominantemente:

* azul extremamente escuro;
* azul profundo;
* azul elétrico;
* azul neon;
* branco azulado.

Evitar excesso de cores.

---

# 21. PALETA DE CORES

### Background principal

`#040D1A`

### Background secundário

`#0A1E33`

### Cards

`#13263F`

### Azul neon principal

`#00BFFF`

### Azul neon claro

`#33CCFF`

### Azul royal

`#005F9E`

### Texto principal

`#E0E6EE`

Utilizar os tons neon principalmente para:

* CTA;
* indicadores;
* ícones ativos;
* progresso;
* elementos importantes;
* logo;
* efeitos de glow.

Não utilizar neon em excesso.

---

# 22. LOGO

A identidade possui como elemento principal o:

**símbolo universal masculino ♂**

O símbolo deve aparecer em azul neon.

O fundo deve ser azul extremamente escuro.

A estética deve transmitir:

* força;
* elegância;
* tecnologia;
* masculinidade;
* mistério;
* exclusividade.

O símbolo pode possuir um glow azul sutil.

---

# 23. UI / UX

O design deve seguir princípios de:

* Material 3 quando apropriado;
* dark mode;
* minimalismo;
* cards arredondados;
* espaçamento generoso;
* hierarquia visual clara;
* animações sutis;
* microinterações;
* glow controlado;
* gradientes discretos;
* ícones simples.

A interface não deve parecer um aplicativo gamer.

Não utilizar excesso de neon, sombras ou efeitos.

O objetivo é parecer um produto premium.

---

# 24. TOM DE VOZ

O Man Hub deve falar com o usuário de forma:

* direta;
* madura;
* confiante;
* masculina;
* elegante;
* motivadora;
* racional.

Evitar:

* frases clichês de coach;
* promessas absurdas;
* masculinidade tóxica;
* linguagem de superioridade;
* ataques a outros grupos;
* promessas de sucesso garantido.

A mensagem deve ser:

**"Você pode evoluir. Nós vamos te mostrar como."**

---

# 25. TECNOLOGIA

O aplicativo será desenvolvido inicialmente utilizando:

### Frontend

Flutter.

O projeto deve ser preparado para:

* Android;
* iOS;
* futuramente Web, se fizer sentido.

### Backend

Firebase.

Utilizar:

* Firebase Authentication;
* Cloud Firestore;
* Firebase Storage;
* Cloud Functions.

Outros serviços podem ser adicionados quando necessários.

---

# 26. ARQUITETURA DE SOFTWARE

Priorizar uma arquitetura escalável.

Sugestão:

Feature-first + Clean Architecture + Repository Pattern.

Separação conceitual:

`presentation`

`domain`

`data`

`repositories`

`services`

`models`

`widgets`

`core`

A arquitetura pode ser adaptada se existir uma solução melhor.

O mais importante é:

* baixo acoplamento;
* alta reutilização;
* código organizado;
* facilidade de manutenção;
* escalabilidade.

---

# 27. ESTRUTURA DE DADOS

O banco deverá ser pensado para suportar:

### Users

Dados do usuário.

### UserProfile

Características físicas, objetivos e estilo.

### Trainings

Treinamentos.

### TrainingModules

Módulos.

### Lessons

Aulas.

### UserProgress

Progresso individual.

### Products

Produtos do shopping.

### Recommendations

Recomendações.

### Purchases

Compras.

### PremiumContent

Conteúdos premium.

### AIAnalysis

Análises realizadas pela IA.

A estrutura exata do Firestore deverá ser definida durante o desenvolvimento considerando escalabilidade, segurança e custo.

---

# 28. SEGURANÇA

O sistema deverá utilizar Firebase Security Rules corretamente.

Um usuário nunca deve conseguir acessar ou modificar dados privados de outro usuário.

Dados sensíveis não devem ser expostos ao cliente sem necessidade.

As Cloud Functions devem ser utilizadas quando uma operação não puder ser realizada com segurança diretamente pelo aplicativo.

---

# 29. PRIVACIDADE E FOTOS

Como futuramente poderão ser utilizadas fotografias para análise visual, a arquitetura deverá considerar privacidade desde o início.

O usuário deverá ter controle sobre seus dados.

Fotos não devem ser mantidas indefinidamente sem necessidade.

A implementação da IA deverá seguir princípios de minimização de dados e segurança.

---

# 30. MVP

Apesar de o projeto possuir uma visão grande, o desenvolvimento inicial deve priorizar um MVP.

O primeiro lançamento deve conter:

* autenticação;
* onboarding;
* questionário;
* perfil;
* Home;
* Jornada do Homem de Valor;
* módulos e aulas;
* progresso;
* acesso vitalício;
* tela de pagamento;
* área básica de shopping;
* recomendações baseadas em regras simples;
* configurações.

A IA avançada pode entrar posteriormente.

---

# 31. ROADMAP FUTURO

Depois do MVP:

### Fase 2

* IA de análise de imagem;
* consultor pessoal de IA;
* recomendações inteligentes;
* sistema de níveis;
* notificações personalizadas.

### Fase 3

* comunidade;
* desafios;
* gamificação;
* ranking pessoal;
* novos treinamentos;
* conteúdo premium.

### Fase 4

* marketplace;
* parcerias;
* consultores;
* experiências personalizadas;
* expansão internacional.

---

# 32. PRINCÍPIO FUNDAMENTAL DE DESENVOLVIMENTO

Não tentar desenvolver tudo de uma vez.

Sempre separar funcionalidades em:

**MVP**

**Versão 1.x**

**Roadmap futuro**

O projeto deve priorizar uma primeira versão extremamente bem executada em vez de uma primeira versão gigantesca e instável.

---

# 33. PAPEL DO AGENTE DE IA

O agente responsável pelo desenvolvimento deverá atuar como:

* desenvolvedor Flutter;
* arquiteto de software;
* especialista em UX/UI;
* especialista em Firebase;
* analista de produto.

Antes de implementar uma funcionalidade complexa, deve avaliar:

1. Qual problema ela resolve?
2. Ela é necessária no MVP?
3. Qual impacto terá na arquitetura?
4. Qual será o custo de manutenção?
5. Existe uma solução mais simples?
6. Como essa funcionalidade poderá escalar futuramente?

Quando houver mais de uma solução técnica possível, o agente deve apresentar as alternativas e recomendar a mais adequada.

Não deve implementar funcionalidades complexas apenas porque são possíveis.

---

# 34. OBJETIVO FINAL

O objetivo não é simplesmente construir um aplicativo bonito.

O objetivo é criar uma plataforma que possa se transformar em uma **marca de desenvolvimento masculino**.

O Man Hub deve fazer o usuário sentir:

> "Eu estou evoluindo."

A transformação deve começar pela mentalidade, passar pelo comportamento e eventualmente refletir na imagem.

O usuário deve entrar buscando melhorar sua aparência e permanecer porque percebe que o aplicativo está ajudando a melhorar sua vida como um todo.

## MAN HUB

**Mais do que estilo. Uma nova versão de você.**
