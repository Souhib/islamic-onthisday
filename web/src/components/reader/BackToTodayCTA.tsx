// Cold-landing escape hatch for permalink pages. Under the pure-ritual
// model, every detail route ends with a path back to today's reading —
// search-engine traffic that lands on /events/<slug> needs somewhere to
// go besides the back button.

import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { FriezeRule } from "@/components/design";

export function BackToTodayCTA() {
  const { t } = useTranslation();
  return (
    <div className="mt-10">
      <FriezeRule marginTop={0} marginBottom={14} rosetteOnly />
      <div className="text-center">
        <Link
          to="/"
          className="thaqafa-link font-mono text-[12px] uppercase tracking-[2px] text-accent"
        >
          {t("back_to_todays_reading")}
        </Link>
      </div>
    </div>
  );
}
