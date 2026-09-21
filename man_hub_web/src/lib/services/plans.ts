import { db } from "@/lib/firebase";
import { doc, getDoc, onSnapshot } from "firebase/firestore";

export interface PlanData {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  billingPeriod: string;
  active: boolean;
}

export const DEFAULT_PASS_PLAN: PlanData = {
  id: "man_hub_pass",
  name: "Man Hub Pass",
  description: "Acesso Ilimitado a Todos os Treinamentos",
  price: 49.9,
  currency: "BRL",
  billingPeriod: "monthly",
  active: true,
};

export async function fetchPlan(planId: string = "man_hub_pass"): Promise<PlanData> {
  try {
    const snap = await getDoc(doc(db, "plans", planId));
    if (snap.exists()) {
      const data = snap.data();
      let parsedPrice = DEFAULT_PASS_PLAN.price;
      if (typeof data.price === "number" && data.price > 0) {
        parsedPrice = data.price;
      } else if (data.price) {
        const n = Number(data.price);
        if (!isNaN(n) && n > 0) parsedPrice = n;
      }

      return {
        id: snap.id,
        name: data.name || DEFAULT_PASS_PLAN.name,
        description: data.description || DEFAULT_PASS_PLAN.description,
        price: parsedPrice,
        currency: data.currency || "BRL",
        billingPeriod: data.billingPeriod || "monthly",
        active: data.active !== false,
      };
    }
  } catch (err) {
    console.warn(`Erro ao buscar plano ${planId} no Firestore:`, err);
  }
  return DEFAULT_PASS_PLAN;
}

export function subscribeToPlan(
  planId: string = "man_hub_pass",
  callback: (plan: PlanData) => void
): () => void {
  try {
    return onSnapshot(doc(db, "plans", planId), (snap) => {
      if (snap.exists()) {
        const data = snap.data();
        let parsedPrice = DEFAULT_PASS_PLAN.price;
        if (typeof data.price === "number" && data.price > 0) {
          parsedPrice = data.price;
        } else if (data.price) {
          const n = Number(data.price);
          if (!isNaN(n) && n > 0) parsedPrice = n;
        }

        callback({
          id: snap.id,
          name: data.name || DEFAULT_PASS_PLAN.name,
          description: data.description || DEFAULT_PASS_PLAN.description,
          price: parsedPrice,
          currency: data.currency || "BRL",
          billingPeriod: data.billingPeriod || "monthly",
          active: data.active !== false,
        });
      } else {
        callback(DEFAULT_PASS_PLAN);
      }
    });
  } catch (err) {
    console.warn(`Erro ao escutar plano ${planId}:`, err);
    callback(DEFAULT_PASS_PLAN);
    return () => {};
  }
}
