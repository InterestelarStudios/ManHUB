// Declaração de tipos globais para pixels de rastreamento
declare global {
  interface Window {
    fbq?: (...args: any[]) => void;
    _fbq?: any;
    gtag?: (...args: any[]) => void;
    dataLayer?: any[];
    ttq?: any;
  }
}

/**
 * Dispara evento de PageView em todas as ferramentas configuradas
 */
export function trackPageView(url?: string) {
  if (typeof window === "undefined") return;

  const currentUrl = url || window.location.href;

  // Meta Pixel (Facebook / Instagram Ads)
  if (window.fbq) {
    window.fbq("track", "PageView");
  }

  // Google Analytics / Google Ads
  if (window.gtag) {
    window.gtag("event", "page_view", {
      page_location: currentUrl,
    });
  }

  // TikTok Pixel
  if (window.ttq) {
    window.ttq.page();
  }
}

/**
 * Dispara evento de Visualização de Conteúdo (ViewContent) ao abrir um treinamento
 */
export function trackViewContent(data: {
  id: string;
  name: string;
  price?: number;
  category?: string;
}) {
  if (typeof window === "undefined") return;

  const price = data.price || 0;

  // Meta Pixel
  if (window.fbq) {
    window.fbq("track", "ViewContent", {
      content_ids: [data.id],
      content_name: data.name,
      content_category: data.category || "Treinamentos",
      content_type: "product",
      value: price,
      currency: "BRL",
    });
  }

  // Google Analytics / Ads
  if (window.gtag) {
    window.gtag("event", "view_item", {
      currency: "BRL",
      value: price,
      items: [
        {
          item_id: data.id,
          item_name: data.name,
          item_category: data.category || "Treinamentos",
          price: price,
        },
      ],
    });
  }

  // TikTok Pixel
  if (window.ttq) {
    window.ttq.track("ViewContent", {
      content_id: data.id,
      content_name: data.name,
      value: price,
      currency: "BRL",
    });
  }
}

/**
 * Dispara evento de Início de Checkout (InitiateCheckout) ao abrir pagamento
 */
export function trackInitiateCheckout(data: {
  id: string;
  name: string;
  price: number;
  isSubscription?: boolean;
}) {
  if (typeof window === "undefined") return;

  // Meta Pixel
  if (window.fbq) {
    window.fbq("track", "InitiateCheckout", {
      content_ids: [data.id],
      content_name: data.name,
      content_type: data.isSubscription ? "subscription" : "product",
      value: data.price,
      currency: "BRL",
    });
  }

  // Google Analytics / Ads
  if (window.gtag) {
    window.gtag("event", "begin_checkout", {
      currency: "BRL",
      value: data.price,
      items: [
        {
          item_id: data.id,
          item_name: data.name,
          price: data.price,
        },
      ],
    });
  }

  // TikTok Pixel
  if (window.ttq) {
    window.ttq.track("InitiateCheckout", {
      content_id: data.id,
      content_name: data.name,
      value: data.price,
      currency: "BRL",
    });
  }
}

/**
 * Dispara evento de Compra Concluída (Purchase)
 */
export function trackPurchase(data: {
  id: string;
  name: string;
  price: number;
  orderId?: string;
  currency?: string;
  isSubscription?: boolean;
}) {
  if (typeof window === "undefined") return;

  const currency = data.currency || "BRL";

  // Meta Pixel
  if (window.fbq) {
    window.fbq("track", "Purchase", {
      content_ids: [data.id],
      content_name: data.name,
      content_type: data.isSubscription ? "subscription" : "product",
      value: data.price,
      currency,
      order_id: data.orderId || undefined,
    });
  }

  // Google Analytics / Ads
  if (window.gtag) {
    window.gtag("event", "purchase", {
      transaction_id: data.orderId || `ORDER-${Date.now()}`,
      currency: "BRL",
      value: data.price,
      items: [
        {
          item_id: data.id,
          item_name: data.name,
          price: data.price,
        },
      ],
    });
  }

  // TikTok Pixel
  if (window.ttq) {
    window.ttq.track("CompletePayment", {
      content_id: data.id,
      content_name: data.name,
      value: data.price,
      currency: "BRL",
    });
  }
}

/**
 * Dispara evento de Cadastro Completo (CompleteRegistration)
 */
export function trackCompleteRegistration(method = "email") {
  if (typeof window === "undefined") return;

  // Meta Pixel
  if (window.fbq) {
    window.fbq("track", "CompleteRegistration", {
      content_name: "Registro de Usuário",
      status: "success",
      registration_method: method,
    });
  }

  // Google Analytics / Ads
  if (window.gtag) {
    window.gtag("event", "sign_up", {
      method: method,
    });
  }

  // TikTok Pixel
  if (window.ttq) {
    window.ttq.track("CompleteRegistration", {
      registration_method: method,
    });
  }
}
