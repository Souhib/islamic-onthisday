// "Scholarly views" drawer — opens from the dispute badge.
//
// Built on top of `@radix-ui/react-dialog` for accessibility (focus trap,
// scroll lock, escape-to-close). The visual layer remains the editorial
// drawer treatment: rises from the bottom, paper background, frieze rule
// header, ranked positions in roman numerals.

import * as Dialog from "@radix-ui/react-dialog";
import { useTranslation } from "react-i18next";
import { FriezeRule } from "@/components/design";
import type { EventDetail } from "@/api/generated/types.gen";

const ROMAN = ["i", "ii", "iii", "iv", "v", "vi"];
const WEIGHT_LABEL_KEY: Record<string, string> = {
  primary: "weight_primary",
  notable: "weight_notable",
  minority: "weight_minority",
};

interface Props {
  event: EventDetail;
  onClose: () => void;
}

export function DisputedDrawer({ event, onClose }: Props) {
  const { t } = useTranslation();
  const positions = event.disputedPositions ?? [];
  const topicKey = event.disputeAbout ? `dispute_${event.disputeAbout}` : "dispute_date";
  const topic = t(topicKey);

  return (
    <Dialog.Root open onOpenChange={(open) => !open && onClose()}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 z-40 bg-[rgba(20,18,12,0.45)] dark:bg-[rgba(8,10,14,0.7)] data-[state=open]:animate-[thaqafa-fade_180ms_ease-out]" />
        <Dialog.Content
          className="fixed bottom-0 left-1/2 z-50 max-h-[86vh] w-[min(680px,96vw)] -translate-x-1/2 overflow-auto border-t border-rule bg-paper px-9 pt-8 pb-10 text-ink shadow-[0_-16px_40px_rgba(0,0,0,0.18)] data-[state=open]:animate-[thaqafa-rise_240ms_cubic-bezier(.2,.7,.2,1)]"
          aria-label={t("scholarly_views_label")}
        >
          <FriezeRule label={t("scholarly_views_label")} marginTop={0} marginBottom={22} />

          <Dialog.Title asChild>
            <h2 className="m-0 mt-1.5 text-center font-serif text-[24px] font-medium leading-[1.1] tracking-[-0.4px] text-ink text-balance">
              {t("classical_record_records")} {positions.length || ""} {t("positions_word")}
            </h2>
          </Dialog.Title>

          <Dialog.Description asChild>
            <p className="mx-auto my-3 mb-[26px] max-w-[520px] text-center font-serif text-[16px] italic leading-[1.5] text-ink-soft text-pretty">
              Classical Sunni sources agree the event took place but disagree on <em>{topic}</em>.
              We preserve every attested position; none is silenced.
            </p>
          </Dialog.Description>

          {positions.map((p, i) => {
            const weightKey = WEIGHT_LABEL_KEY[p.weight] ?? "weight_minority";
            return (
              <div
                key={i}
                className="grid grid-cols-[32px_1fr_auto] items-baseline gap-3.5 border-b border-rule-soft py-4 first:border-t first:border-rule"
              >
                <span className="font-mono text-[11px] uppercase tracking-[1px] text-accent">
                  {ROMAN[i] ?? p.rank}
                </span>
                <div>
                  <div className="font-serif text-[18px] font-medium leading-[1.2] text-ink">
                    {p.value}
                  </div>
                  <div className="mt-1.5 font-mono text-[12.5px] tracking-[0.4px] text-ink-mute">
                    {p.scholars}
                  </div>
                </div>
                <span className="whitespace-nowrap font-mono text-[11.5px] uppercase tracking-[1.2px] text-ink-mute">
                  {t(weightKey)}
                </span>
              </div>
            );
          })}

          <div className="mt-7 flex justify-center">
            <Dialog.Close asChild>
              <button
                type="button"
                className="cursor-pointer border border-rule bg-transparent px-[22px] py-2.5 font-mono text-[12.5px] uppercase tracking-[1.6px] text-ink"
              >
                {t("close")}
              </button>
            </Dialog.Close>
          </div>
        </Dialog.Content>
      </Dialog.Portal>

      <style>{`
        @keyframes thaqafa-fade { from { opacity: 0 } to { opacity: 1 } }
        @keyframes thaqafa-rise { from { transform: translate(-50%, 24px); opacity: 0 } to { transform: translate(-50%, 0); opacity: 1 } }
      `}</style>
    </Dialog.Root>
  );
}
