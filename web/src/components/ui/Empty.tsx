// Italic-serif empty state — used wherever a query returns zero results or
// the API call errors out.

interface Props {
  message: string;
}

export function Empty({ message }: Props) {
  return <div className="py-[60px] text-center font-serif italic text-ink-mute">{message}</div>;
}
