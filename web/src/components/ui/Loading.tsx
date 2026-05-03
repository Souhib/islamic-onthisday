// Single shared loading affordance — the previous codebase reimplemented
// this six times across routes. Spelled in mono uppercase per the editorial
// design language.

import { useTranslation } from "react-i18next";

interface Props {
  /** Override the default "loading" label (i18n key or pre-translated text). */
  labelKey?: string;
}

export function Loading({ labelKey }: Props) {
  const { t } = useTranslation();
  const label = labelKey ? t(labelKey) : t("loading");
  return (
    <div className="py-[60px] text-center font-mono text-[12px] uppercase tracking-[2px] text-ink-mute">
      · {label} ·
    </div>
  );
}
