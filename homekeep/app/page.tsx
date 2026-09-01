import Link from 'next/link';

export default function Home(){
  return <main className="shell">
    <div className="top"><div className="brand">HomeKeep</div><Link className="btn ghost" href="/auth">Sign in</Link></div>
    <section className="hero">
      <div className="card"><h1 style={{fontSize:44,lineHeight:1.05}}>Never forget the little jobs that protect your home.</h1><p className="muted" style={{fontSize:18}}>Track filters, detectors, gutters, appliances, plumbing and recurring household maintenance in one simple schedule.</p><Link className="btn primary" href="/auth">Create free account</Link></div>
      <div className="card"><div className="muted">HomeKeep Plus</div><div style={{fontSize:34,fontWeight:800,marginTop:8}}>$0.99</div><div className="muted">per month</div><p className="muted">Unlimited reminders, household sharing, history, receipts and smart recommendations.</p></div>
    </section>
  </main>
}
