import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { EightPointStar, Eyebrow, FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { cn } from "@/lib/utils";
import { useLanguage } from "@/providers/LanguageProvider";

const SKILLS = [
  "Python",
  "FastAPI",
  "Flask",
  "React",
  "TypeScript",
  "PostgreSQL",
  "MySQL",
  "AWS",
  "GCP",
  "Docker",
  "Terraform",
  "Ansible",
  "Gitlab CI/CD",
  "Traefik",
  "Prefect",
  "SQLModel",
  "Tailwind CSS",
  "OpenCV",
  "Pandas",
  "NumPy",
  "Scikit-learn",
];

const EXPERIENCE_KEYS = ["madura", "snap", "enedis", "bnp", "cloudeasier"] as const;

interface ExternalLinkProps {
  href: string;
  label: string;
}

function ExternalLink({ href, label }: ExternalLinkProps) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className="inline-flex items-center gap-1.5 border border-rule bg-transparent px-3.5 py-2 font-mono text-[12.5px] uppercase tracking-[1.6px] text-ink-soft transition-colors hover:border-ink hover:text-ink"
    >
      {label}
      <span aria-hidden="true">↗</span>
    </a>
  );
}

function AboutPage() {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();

  return (
    <PageShell title={t("about.title")}>
      <div className="mx-auto max-w-[720px] pt-2 pb-12">
        {/* Hero */}
        <section className="flex flex-col items-center gap-1">
          <EightPointStar size={28} className="text-accent" strokeWidth={0.6} />
          <Eyebrow color="accent" className="mt-3">
            · {t("about.title")} ·
          </Eyebrow>
          <p
            dir={isRTL ? "rtl" : "ltr"}
            className={cn(
              "mt-3 max-w-[560px] text-center text-[17px] leading-[1.55] text-ink-soft text-pretty",
              isRTL ? "font-arabic" : "font-serif italic",
            )}
          >
            {t("about.subtitle")}
          </p>
        </section>

        <FriezeRule rosetteOnly marginTop={28} marginBottom={28} />

        {/* Project purpose */}
        <section className="mb-10">
          <Eyebrow color="accent">· {t("about.project_purpose_title")} ·</Eyebrow>
          <p
            dir={isRTL ? "rtl" : "ltr"}
            className={cn(
              "mt-3 text-[18px] leading-[1.7] text-ink-soft text-pretty",
              isRTL ? "font-arabic leading-[1.95]" : "font-serif",
            )}
          >
            {t("about.project_purpose_body")}
          </p>
        </section>

        <FriezeRule label={t("about.title")} marginTop={36} marginBottom={26} />

        {/* Person hero */}
        <section className="mb-10 flex flex-col items-center gap-5 sm:flex-row sm:items-center sm:gap-7">
          <img
            src="/souhib.jpeg"
            alt={t("about.name")}
            className="h-32 w-32 shrink-0 border border-rule object-cover sm:h-36 sm:w-36"
          />
          <div className="flex flex-col items-center text-center sm:items-start sm:text-start">
            <h2
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "text-[clamp(28px,3.2vw,38px)] font-medium leading-[1.05] text-ink",
                isRTL ? "font-arabic" : "font-serif tracking-[-0.8px]",
              )}
            >
              {t("about.name")}
            </h2>
            <Eyebrow color="ink-mute" className="mt-2">
              {t("about.role")}
            </Eyebrow>
            <p
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "mt-3 max-w-[520px] text-[17.5px] leading-[1.6] text-ink-soft text-pretty",
                isRTL ? "font-arabic leading-[1.9]" : "font-serif",
              )}
            >
              {t("about.bio")}
            </p>
          </div>
        </section>

        {/* Education */}
        <section className="mb-10">
          <Eyebrow color="accent">· {t("about.education_title")} ·</Eyebrow>
          <ul className="mt-3 flex flex-col gap-3">
            {(["education_epitech", "education_sfsu"] as const).map((key) => (
              <li
                key={key}
                className="border-b border-rule-soft pb-3 font-serif text-[18px] leading-[1.4] text-ink"
              >
                {t(`about.${key}`)}
              </li>
            ))}
          </ul>
        </section>

        {/* Experience */}
        <section className="mb-10">
          <Eyebrow color="accent">· {t("about.experience_title")} ·</Eyebrow>
          <ul className="mt-3 flex flex-col gap-3">
            {EXPERIENCE_KEYS.map((slug) => (
              <li key={slug} className="border-b border-rule-soft pb-3">
                <div className="font-serif text-[18px] font-medium leading-[1.3] text-ink">
                  {t(`about.experience_${slug}_title`)}
                </div>
                <div className="mt-1.5 font-mono text-[12px] uppercase tracking-[1.4px] text-ink-mute">
                  {t(`about.experience_${slug}_period`)}
                </div>
              </li>
            ))}
          </ul>
        </section>

        {/* Skills */}
        <section className="mb-10">
          <Eyebrow color="accent">· {t("about.skills_title")} ·</Eyebrow>
          <div className="mt-3 flex flex-wrap gap-2">
            {SKILLS.map((skill) => (
              <span
                key={skill}
                className="border border-rule px-3 py-1.5 font-mono text-[13px] tracking-[0.4px] text-ink-soft"
              >
                {skill}
              </span>
            ))}
          </div>
        </section>

        {/* Other projects */}
        <section className="mb-10">
          <Eyebrow color="accent">· {t("about.other_projects_title")} ·</Eyebrow>
          <ul className="mt-3 flex flex-col gap-4">
            {(["majlisna", "latabdhir"] as const).map((slug) => {
              const url = `https://${t(`about.other_projects_${slug}_link`)}`;
              return (
                <li key={slug} className="border-b border-rule-soft pb-4">
                  <div className="flex items-baseline justify-between gap-3 flex-wrap">
                    <a
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="font-serif text-[19px] font-medium leading-[1.2] text-ink hover:underline"
                    >
                      {t(`about.other_projects_${slug}_title`)}
                    </a>
                    <a
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="font-mono text-[11.5px] uppercase tracking-[1.4px] text-accent underline decoration-accent/40 underline-offset-[5px] transition-colors hover:decoration-accent"
                    >
                      {t(`about.other_projects_${slug}_link`)} ↗
                    </a>
                  </div>
                  <p className="mt-2 text-[16px] leading-[1.55] text-ink-soft">
                    {t(`about.other_projects_${slug}_desc`)}
                  </p>
                </li>
              );
            })}
          </ul>
        </section>

        {/* Mentoring */}
        <section className="mb-10 border border-accent/40 bg-paper-hi/40 p-6">
          <Eyebrow color="accent">· {t("about.mentoring_title")} ·</Eyebrow>
          <p
            dir={isRTL ? "rtl" : "ltr"}
            className={cn(
              "mt-3 text-[17px] leading-[1.65] text-ink-soft",
              isRTL ? "font-arabic leading-[1.9]" : "font-serif",
            )}
          >
            {t("about.mentoring_body")}
          </p>
          <div className="mt-5 flex flex-wrap gap-3">
            <ExternalLink href="mailto:souhib.t@hotmail.fr" label="souhib.t@hotmail.fr" />
            <ExternalLink href="tel:+33643142020" label="+33 6 43 14 20 20" />
          </div>
        </section>

        {/* Charities */}
        <section className="mb-10">
          <Eyebrow color="accent">· {t("about.charity_title")} ·</Eyebrow>
          <p
            dir={isRTL ? "rtl" : "ltr"}
            className={cn(
              "mt-3 text-[16.5px] leading-[1.6] text-ink-soft",
              isRTL ? "font-arabic" : "font-serif italic",
            )}
          >
            {t("about.charity_subtitle")}
          </p>
          <ul className="mt-4 flex flex-col gap-4">
            {[
              {
                name: "Human Appeal",
                href: "https://humanappeal.fr/",
                desc: t("about.charity_human_appeal_desc"),
              },
              {
                name: "Ummah Charity",
                href: "https://ummahcharity.org/",
                desc: t("about.charity_ummah_charity_desc"),
              },
            ].map((c) => (
              <li key={c.name} className="border-b border-rule-soft pb-4">
                <div className="flex items-baseline justify-between gap-3 flex-wrap">
                  <a
                    href={c.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="font-serif text-[19px] font-medium leading-[1.2] text-ink hover:underline"
                  >
                    {c.name}
                  </a>
                  <a
                    href={c.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="font-mono text-[11.5px] uppercase tracking-[1.4px] text-accent underline decoration-accent/40 underline-offset-[5px] transition-colors hover:decoration-accent"
                  >
                    {t("about.charity_donate")} ↗
                  </a>
                </div>
                <p className="mt-2 text-[16px] leading-[1.55] text-ink-soft">{c.desc}</p>
              </li>
            ))}
          </ul>
        </section>

        {/* Contact */}
        <section>
          <Eyebrow color="accent">· {t("about.contact_title")} ·</Eyebrow>
          <div className="mt-3 flex flex-wrap gap-2.5">
            <ExternalLink href="mailto:souhib.t@hotmail.fr" label={t("about.contact_email")} />
            <ExternalLink href="tel:+33643142020" label={t("about.contact_phone")} />
            <ExternalLink
              href="https://www.linkedin.com/in/souhib-trabelsi/"
              label={t("about.contact_linkedin")}
            />
            <ExternalLink href="https://github.com/Souhib" label={t("about.contact_github")} />
          </div>
        </section>
      </div>
    </PageShell>
  );
}

export const Route = createFileRoute("/about")({
  component: AboutPage,
});
