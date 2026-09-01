import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'HomeKeep',
  description: 'Simple household maintenance reminders that protect your home.'
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
