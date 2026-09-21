const fs = require('fs');

const iconB64 = fs.readFileSync('c:/flutter_projects/Man Hub/man_hub_web/public/manhub_icon.png').toString('base64');
const presencaB64 = fs.readFileSync('c:/flutter_projects/Man Hub/scratch/presenca.jpg').toString('base64');

const html = `<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');

    :root {
      --neon-primary: #00BFFF;
      --neon-light: #33CCFF;
      --royal-blue: #005F9E;
      --gold-accent: #E5A93C;
      --card-border: rgba(0, 191, 255, 0.15);
      --text-secondary: #94A3B8;
      --text-muted: #64748B;
      --radius-md: 12px;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      font-family: 'Outfit', 'Plus Jakarta Sans', sans-serif;
    }

    html, body {
      background: transparent !important;
      margin: 0;
      padding: 0;
      width: 500px;
      height: 740px;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }

    .mockupContainer {
      position: relative;
      width: 360px;
      height: 640px;
      margin: 0 auto;
    }

    .phoneFrame {
      position: relative;
      width: 100%;
      height: 640px;
      background: #02070E;
      border-radius: 46px;
      border: 9px solid #141B26;
      box-shadow: 
        0 0 0 2px rgba(0, 191, 255, 0.3),
        0 25px 60px rgba(0, 0, 0, 0.8),
        0 0 45px rgba(0, 191, 255, 0.22);
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }

    .phoneHeaderBar {
      position: absolute;
      top: 10px;
      left: 50%;
      transform: translateX(-50%);
      width: 110px;
      height: 22px;
      background: #09121E;
      border-radius: 12px;
      z-index: 50;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
    }

    .cameraLens {
      width: 9px;
      height: 9px;
      background: #030810;
      border-radius: 50%;
      border: 1px solid rgba(0, 191, 255, 0.3);
    }

    .speakerMesh {
      width: 36px;
      height: 4px;
      background: #1C2634;
      border-radius: 2px;
    }

    .phoneScreen {
      position: relative;
      flex: 1;
      background: #040D1A;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      user-select: none;
    }

    .storyBars {
      display: flex;
      gap: 4px;
      padding: 38px 14px 10px;
      z-index: 20;
    }

    .barTrack {
      flex: 1;
      height: 3px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 2px;
      overflow: hidden;
    }

    .barFill {
      height: 100%;
      background: var(--neon-primary);
      box-shadow: 0 0 8px var(--neon-primary);
    }

    .appTopBar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 4px 16px 12px;
      z-index: 20;
    }

    .appBrand {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .appCourseTitle {
      font-size: 12px;
      font-weight: 700;
      color: #FFFFFF;
      letter-spacing: 0.02em;
    }

    .appActions {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .iconBtn {
      width: 30px;
      height: 30px;
      border-radius: 50%;
      background: rgba(0, 0, 0, 0.4);
      border: 1px solid rgba(255, 255, 255, 0.1);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
    }

    .slideContent {
      flex: 1;
      position: relative;
      display: flex;
      flex-direction: column;
      justify-content: flex-end;
      padding: 20px;
      z-index: 10;
    }

    .slideBackground {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-size: cover;
      background-position: center;
      filter: brightness(0.78);
      z-index: 1;
    }

    .slideGradientOverlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(
        to bottom,
        rgba(4, 13, 26, 0.3) 0%,
        rgba(4, 13, 26, 0.65) 50%,
        rgba(4, 13, 26, 0.96) 100%
      );
      z-index: 2;
    }

    .slideCard {
      position: relative;
      z-index: 5;
      background: rgba(7, 20, 38, 0.88);
      backdrop-filter: blur(14px);
      -webkit-backdrop-filter: blur(14px);
      border: 1px solid var(--card-border);
      border-radius: var(--radius-md);
      padding: 16px;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
    }

    .slideBadge {
      display: inline-block;
      padding: 3px 8px;
      background: rgba(0, 191, 255, 0.2);
      border: 1px solid rgba(0, 191, 255, 0.4);
      border-radius: 6px;
      font-size: 10px;
      font-weight: 700;
      color: var(--neon-light);
      letter-spacing: 0.05em;
      text-transform: uppercase;
      margin-bottom: 8px;
    }

    .slideTitle {
      font-size: 16px;
      font-weight: 800;
      color: #FFFFFF;
      line-height: 1.25;
      margin-bottom: 6px;
    }

    .slideText {
      font-size: 12px;
      color: var(--text-secondary);
      line-height: 1.45;
    }

    .bottomNav {
      height: 52px;
      background: rgba(7, 20, 38, 0.95);
      border-top: 1px solid rgba(0, 191, 255, 0.15);
      display: flex;
      align-items: center;
      justify-content: space-around;
      padding: 0 10px;
      z-index: 30;
    }

    .navItem {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 2px;
      color: var(--text-muted);
      font-size: 9px;
    }

    .navActive {
      color: var(--neon-primary);
    }

    .floatingBadge1 {
      position: absolute;
      top: 15%;
      left: -28px;
      background: rgba(7, 20, 38, 0.94);
      border: 1px solid rgba(0, 191, 255, 0.35);
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.5), 0 0 20px rgba(0, 191, 255, 0.2);
      border-radius: var(--radius-md);
      padding: 10px 14px;
      display: flex;
      align-items: center;
      gap: 10px;
      z-index: 60;
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
    }

    .floatingBadge2 {
      position: absolute;
      bottom: 22%;
      right: -28px;
      background: rgba(7, 20, 38, 0.94);
      border: 1px solid rgba(229, 169, 60, 0.35);
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.5), 0 0 20px rgba(229, 169, 60, 0.2);
      border-radius: var(--radius-md);
      padding: 10px 14px;
      display: flex;
      align-items: center;
      gap: 10px;
      z-index: 60;
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
    }

    .badgeIconCircle {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .badgeText {
      display: flex;
      flex-direction: column;
    }

    .badgeLabel {
      font-size: 9px;
      text-transform: uppercase;
      color: var(--text-secondary);
      font-weight: 600;
      letter-spacing: 0.05em;
    }

    .badgeVal {
      font-size: 13px;
      font-weight: 700;
      color: #FFFFFF;
    }
  </style>
</head>
<body>
  <div class="mockupContainer">
    <!-- Floating Badge 1 -->
    <div class="floatingBadge1">
      <div class="badgeIconCircle" style="background: rgba(0, 191, 255, 0.2); color: var(--neon-primary);">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00BFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/><path d="M5 3v4"/><path d="M19 17v4"/><path d="M3 5h4"/><path d="M17 19h4"/></svg>
      </div>
      <div class="badgeText">
        <span class="badgeLabel">Desenvolvimento</span>
        <span class="badgeVal">Academia Masculina</span>
      </div>
    </div>

    <!-- Floating Badge 2 -->
    <div class="floatingBadge2">
      <div class="badgeIconCircle" style="background: rgba(229, 169, 60, 0.2); color: var(--gold-accent);">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="#E5A93C" stroke="#E5A93C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/></svg>
      </div>
      <div class="badgeText">
        <span class="badgeLabel">Telas Salvas</span>
        <span class="badgeVal">Dicas Favoritadas</span>
      </div>
    </div>

    <!-- Phone Frame -->
    <div class="phoneFrame">
      <div class="phoneHeaderBar">
        <div class="cameraLens"></div>
        <div class="speakerMesh"></div>
      </div>

      <div class="phoneScreen">
        <!-- Story Bars -->
        <div class="storyBars">
          <div class="barTrack"><div class="barFill" style="width: 100%;"></div></div>
          <div class="barTrack"><div class="barFill" style="width: 100%;"></div></div>
          <div class="barTrack"><div class="barFill" style="width: 100%;"></div></div>
        </div>

        <!-- Top Bar inside App -->
        <div class="appTopBar">
          <div class="appBrand">
            <img src="data:image/png;base64,${iconB64}" width="22" height="22" style="object-fit: contain; filter: drop-shadow(0 0 6px rgba(0, 191, 255, 0.7));" />
            <span class="appCourseTitle">Presença de Alto Nível</span>
          </div>
          <div class="appActions">
            <div class="iconBtn">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/></svg>
            </div>
            <div class="iconBtn">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>
            </div>
          </div>
        </div>

        <!-- Slide Content -->
        <div class="slideContent">
          <div class="slideBackground" style="background-image: url(data:image/jpeg;base64,${presencaB64});"></div>
          <div class="slideGradientOverlay"></div>

          <div class="slideCard">
            <span class="slideBadge">Liderança & Magnetismo</span>
            <h3 class="slideTitle">Postura e Olhar Firme</h3>
            <p class="slideText">Contato visual inabalável, comunicação não-verbal assertiva e serenidade sob pressão impõem respeito natural onde quer que você esteja.</p>
          </div>
        </div>

        <!-- Bottom Nav -->
        <div class="bottomNav">
          <div class="navItem navActive">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#00BFFF" stroke-width="2"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            <span>Início</span>
          </div>
          <div class="navItem">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748B" stroke-width="2"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z"/><path d="M6 6h10"/><path d="M6 10h10"/></svg>
            <span>Treinos</span>
          </div>
          <div class="navItem">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748B" stroke-width="2"><path d="M20.38 3.46 16 2a4 4 0 0 1-8 0L3.62 3.46a2 2 0 0 0-1.34 2.23l.58 3.47a1 1 0 0 0 .99.84H6v10c0 1.1.9 2 2 2h8a2 2 0 0 0 2-2V10h2.15a1 1 0 0 0 .99-.84l.58-3.47a2 2 0 0 0-1.34-2.23z"/></svg>
            <span>Armário</span>
          </div>
          <div class="navItem">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748B" stroke-width="2"><circle cx="12" cy="8" r="5"/><path d="M20 21a8 8 0 1 0-16 0"/></svg>
            <span>Perfil</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>`;

fs.writeFileSync('c:/flutter_projects/Man Hub/scratch/render_mockup.html', html, 'utf8');
console.log('SUCCESS: render_mockup.html generated');
