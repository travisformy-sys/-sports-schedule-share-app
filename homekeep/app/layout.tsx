import './globals.css';
import './notifications.css';
import './marketing.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'HomeKeep | Your personalized home maintenance plan',
  description: 'Turn your home’s age, systems and features into a simple maintenance plan with recurring reminders and a useful home-care history.'
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
