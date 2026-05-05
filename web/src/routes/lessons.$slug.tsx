import { createFileRoute } from "@tanstack/react-router";
import { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useLessonQuery } from "@/api/lessons";
import { BackToTodayCTA } from "@/components/reader/BackToTodayCTA";
import { DetailHeader } from "@/components/reader/DetailHeader";
import { LessonReader } from "@/components/reader/LessonReader";
import { Loading } from "@/components/ui/Loading";
import { NotFound } from "@/components/ui/NotFound";
import { trackLessonView } from "@/lib/analytics";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";

function LessonDetailPage() {
  const { slug } = Route.useParams();
  const { t } = useTranslation();
  const { lang } = useLanguage();
  const query = useLessonQuery(slug);

  useEffect(() => {
    trackLessonView(slug);
  }, [slug]);

  useEffect(() => {
    if (query.data) {
      const title = pickLocalised(
        { en: query.data.title, fr: query.data.titleFr, ar: query.data.titleAr },
        lang,
      );
      document.title = `${title} · Islamic On This Day`;
    }
  }, [query.data, lang]);

  return (
    <div className="min-h-full w-full bg-paper font-serif text-ink">
      <DetailHeader eyebrow={`· ${t("lesson_detail")} · ${slug} ·`} />

      <main className="mx-auto max-w-[960px] px-[clamp(24px,4vw,56px)] pt-11 pb-[60px]">
        {query.isPending && <Loading labelKey="loading_lesson" />}
        {query.isError && <NotFound message={`${t("no_lesson_with_slug")} "${slug}"`} />}
        {query.data && (
          <>
            <LessonReader lesson={query.data} />
            <BackToTodayCTA />
          </>
        )}
      </main>
    </div>
  );
}

export const Route = createFileRoute("/lessons/$slug")({
  component: LessonDetailPage,
});
