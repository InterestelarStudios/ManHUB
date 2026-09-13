"use client";

import { useState } from "react";
import Header from "@/components/Header";
import Hero from "@/components/Hero";
import Pillars from "@/components/Pillars";
import AppExperience from "@/components/AppExperience";
import CoursesShowcase from "@/components/CoursesShowcase";
import StyleQuiz from "@/components/StyleQuiz";
import Testimonials from "@/components/Testimonials";
import FAQ from "@/components/FAQ";
import CtaBanner from "@/components/CtaBanner";
import Footer from "@/components/Footer";
import CheckoutModal from "@/components/CheckoutModal";

export default function Home() {
  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState<"pass" | "training">("pass");
  const [selectedTrainingId, setSelectedTrainingId] = useState<string | undefined>();
  const [selectedTrainingTitle, setSelectedTrainingTitle] = useState<string | undefined>();

  const handleOpenPass = () => {
    setSelectedPlan("pass");
    setIsCheckoutOpen(true);
  };

  const handleBuyCourse = (courseId: string, courseTitle: string) => {
    setSelectedPlan("training");
    setSelectedTrainingId(courseId);
    setSelectedTrainingTitle(courseTitle);
    setIsCheckoutOpen(true);
  };

  return (
    <>
      <Header onOpenCheckout={handleOpenPass} />
      <main>
        <Hero />
        <Pillars />
        <AppExperience />
        <CoursesShowcase onBuyCourse={handleBuyCourse} />
        <StyleQuiz />
        <Testimonials />
        <FAQ />
        <CtaBanner />
      </main>
      <Footer />

      <CheckoutModal
        isOpen={isCheckoutOpen}
        onClose={() => setIsCheckoutOpen(false)}
        defaultPlan={selectedPlan}
        defaultTrainingId={selectedTrainingId}
        defaultTrainingTitle={selectedTrainingTitle}
      />
    </>
  );
}
