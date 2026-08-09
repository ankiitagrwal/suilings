import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { CompanyRegistrationForm } from "@/components/company/CompanyRegistrationForm";
import { Building2, ShieldCheck, Briefcase } from "lucide-react";

export const metadata = {
  title: "Register Your Company — Suilings",
  description: "Register your company to post jobs and hire verified Move developers on Suilings.",
};

export default async function CompanyRegisterPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login?redirect=/company/register");
  }

  const admin = createAdminClient();
  const { data: existing } = await admin
    .from("companies")
    .select("slug")
    .eq("admin_user_id", user.id)
    .single();

  if (existing) {
    redirect("/company/dashboard");
  }

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        <div className="container mx-auto px-4 py-10 max-w-3xl">
          <div className="mb-10 text-center">
            <h1 className="text-4xl font-bold mb-3">Register Your Company</h1>
            <p className="text-lg text-muted-foreground max-w-xl mx-auto">
              Join the Suilings hiring platform to find and hire verified Move developers.
            </p>
          </div>

          <div className="grid grid-cols-3 gap-4 mb-10">
            {[
              {
                icon: Building2,
                title: "Create Your Profile",
                desc: "Set up your company page visible to all developers",
              },
              {
                icon: Briefcase,
                title: "Post Job Listings",
                desc: "Reach hundreds of verified Move developers",
              },
              {
                icon: ShieldCheck,
                title: "Hire with Confidence",
                desc: "Every applicant has verifiable on-chain credentials",
              },
            ].map(({ icon: Icon, title, desc }) => (
              <div
                key={title}
                className="text-center p-4 rounded-xl border border-border bg-card"
              >
                <div className="flex justify-center mb-2">
                  <div className="h-10 w-10 rounded-full bg-indigo-500/10 flex items-center justify-center">
                    <Icon className="h-5 w-5 text-indigo-500" />
                  </div>
                </div>
                <h3 className="font-semibold text-sm mb-1">{title}</h3>
                <p className="text-xs text-muted-foreground">{desc}</p>
              </div>
            ))}
          </div>

          <CompanyRegistrationForm />
        </div>
      </div>
      <Footer />
    </>
  );
}
