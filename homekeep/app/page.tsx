import Link from 'next/link';

export default function Home(){
  return <main className="shell">
    <header className="topbar">
      <div className="brandWrap"><div className="brandMark">⌂</div><div className="brand">HomeKeep</div></div>
      <Link className="btn btnGhost btnSmall" href="/auth">Sign in</Link>
    </header>

    <section className="hero">
      <div className="card heroMain">
        <span className="eyebrow">✓ Home maintenance, simplified</span>
        <h1 className="heroTitle">A healthier home, without the mental load.</h1>
        <p className="heroCopy">HomeKeep remembers the filters, detectors, vents, gutters, appliances and seasonal jobs that are easy to forget — and turns them into one simple home care plan.</p>
        <div className="heroActions"><Link className="btn btnPrimary" href="/auth">Start free</Link><Link className="btn btnGhost" href="/dashboard">See the dashboard</Link></div>
        <div className="quickGrid" style={{marginTop:28}}>
          <div className="quickItem"><div className="quickIcon">❄️</div><div><strong>HVAC</strong><div className="quickLabel">Filters & seasonal service</div></div></div>
          <div className="quickItem"><div className="quickIcon">🛡️</div><div><strong>Safety</strong><div className="quickLabel">Smoke & CO detectors</div></div></div>
          <div className="quickItem"><div className="quickIcon">💧</div><div><strong>Plumbing</strong><div className="quickLabel">Water heaters & leaks</div></div></div>
          <div className="quickItem"><div className="quickIcon">🏡</div><div><strong>Exterior</strong><div className="quickLabel">Gutters, roof & seasonal care</div></div></div>
        </div>
      </div>

      <aside className="card">
        <span className="badge">HomeKeep Plus</span>
        <div className="price" style={{marginTop:16}}>$0.99</div><div className="muted">per month</div>
        <div className="plusList">
          <div className="plusItem"><span className="plusCheck">✓</span><span>Unlimited maintenance reminders</span></div>
          <div className="plusItem"><span className="plusCheck">✓</span><span>Household sharing</span></div>
          <div className="plusItem"><span className="plusCheck">✓</span><span>Maintenance history & receipts</span></div>
          <div className="plusItem"><span className="plusCheck">✓</span><span>Smart home-care recommendations</span></div>
        </div>
        <Link className="btn btnPrimary" style={{width:'100%',textAlign:'center'}} href="/auth">Create your home plan</Link>
        <p className="fine" style={{marginBottom:0}}>Start free. Upgrade only when you want the extra tools.</p>
      </aside>
    </section>
  </main>
}
