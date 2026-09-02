import Image from 'next/image';
import Link from 'next/link';

const benefits = [
  {
    icon: '01',
    title: 'Know what comes next',
    copy: 'See the right maintenance jobs in one calm, organized schedule—not scattered notes and calendar alerts.'
  },
  {
    icon: '02',
    title: 'Catch the little things',
    copy: 'Timely reminders help you notice filters, leaks, batteries and seasonal work before they slip your mind.'
  },
  {
    icon: '03',
    title: 'Keep a useful home record',
    copy: 'Track completed work and receipts so your home’s care history is easy to find when you need it.'
  }
];

const steps = [
  ['1', 'Tell us about your home', 'Choose your home type, age, major systems and features—including pets.'],
  ['2', 'Get your personal plan', 'UpkeepCue turns your answers into a practical schedule built around your household.'],
  ['3', 'Let UpkeepCue remember', 'Get recurring reminders, check work off and always know what deserves attention next.']
];

export default function Home() {
  return <main className="marketingPage">
    <header className="marketingNav marketingContainer">
      <Link href="/" className="brandWrap" aria-label="UpkeepCue home">
        <span className="brandMark" aria-hidden="true">⌂</span>
        <span className="brand">UpkeepCue</span>
      </Link>
      <div className="navActions">
        <a className="navLink" href="#how-it-works">How it works</a>
        <Link className="btn btnGhost btnSmall" href="/auth">Sign in</Link>
      </div>
    </header>

    <section className="marketingHero marketingContainer">
      <div className="heroPitch">
        <span className="eyebrow">PERSONALIZED HOME CARE IN ABOUT 2 MINUTES</span>
        <h1 className="marketingTitle">Your home has a lot to remember. <span>Now you don’t have to.</span></h1>
        <p className="marketingLead">UpkeepCue turns your home’s age, systems and features into one simple maintenance plan—so you know what to do, when to do it and what can wait.</p>
        <div className="heroActions marketingActions">
          <Link className="btn btnPrimary primaryCta" href="/auth">Build my free home plan <span aria-hidden="true">→</span></Link>
          <a className="textCta" href="#how-it-works">See how it works <span aria-hidden="true">↓</span></a>
        </div>
        <div className="reassurance" aria-label="Signup details">
          <span><b aria-hidden="true">✓</b> Free to start</span>
          <span><b aria-hidden="true">✓</b> No credit card</span>
          <span><b aria-hidden="true">✓</b> Password-free sign in</span>
        </div>
      </div>

      <div className="heroVisual" aria-label="Example of an UpkeepCue maintenance plan">
        <Image
          className="heroHomeImage"
          src="/upkeepcue-hero.webp"
          alt="A welcoming, well-maintained home in warm natural light"
          fill
          priority
          sizes="(max-width: 850px) 100vw, 46vw"
        />
        <div className="imageWash" />
        <span className="exampleBadge">Example home plan</span>
        <div className="planPreview">
          <div className="previewHead">
            <div>
              <span className="previewKicker">COMING UP</span>
              <strong>Your next 30 days</strong>
            </div>
            <span className="healthPill"><i /> On track</span>
          </div>
          <div className="previewTask">
            <span className="previewIcon" aria-hidden="true">❄</span>
            <span><strong>Replace HVAC filter</strong><small>Due in 4 days</small></span>
            <span className="taskCheck" aria-hidden="true">✓</span>
          </div>
          <div className="previewTask">
            <span className="previewIcon safety" aria-hidden="true">⌁</span>
            <span><strong>Test smoke alarms</strong><small>Due in 12 days</small></span>
            <span className="taskCheck" aria-hidden="true">✓</span>
          </div>
          <div className="previewTask">
            <span className="previewIcon exterior" aria-hidden="true">⌂</span>
            <span><strong>Inspect gutters</strong><small>Due in 28 days</small></span>
            <span className="taskCheck" aria-hidden="true">✓</span>
          </div>
        </div>
      </div>
    </section>

    <section className="trustStrip marketingContainer" aria-label="UpkeepCue benefits">
      <p>One calm place for the work that keeps your home healthy</p>
      <div className="trustItems">
        <span>Personalized schedules</span>
        <span>Recurring reminders</span>
        <span>Maintenance history</span>
        <span>Pet-care tasks</span>
      </div>
    </section>

    <section className="benefitSection marketingContainer">
      <div className="sectionIntro">
        <span className="eyebrow">YOUR HOME DESERVES A SYSTEM</span>
        <h2>Stop carrying your whole house around in your head.</h2>
        <p>UpkeepCue gives the easy-to-forget jobs a dependable home of their own.</p>
      </div>
      <div className="benefitGrid">
        {benefits.map(benefit => <article className="benefitCard" key={benefit.title}>
          <span className="benefitNumber">{benefit.icon}</span>
          <h3>{benefit.title}</h3>
          <p>{benefit.copy}</p>
        </article>)}
      </div>
    </section>

    <section className="howSection" id="how-it-works">
      <div className="marketingContainer howGrid">
        <div className="howPromise">
          <span className="eyebrow light">FROM “I SHOULD” TO “IT’S HANDLED”</span>
          <h2>Your home’s maintenance manual, made for you.</h2>
          <p>Every home is different. UpkeepCue asks only what it needs to build a useful starting plan for yours.</p>
          <div className="planFits">
            <span>House</span><span>Townhome</span><span>Condo</span><span>Manufactured home</span>
          </div>
          <Link className="btn lightCta" href="/auth">Create my free plan →</Link>
        </div>
        <div className="stepsList">
          {steps.map(([number, title, copy]) => <article className="step" key={number}>
            <span className="stepNumber">{number}</span>
            <div><h3>{title}</h3><p>{copy}</p></div>
          </article>)}
        </div>
      </div>
    </section>

    <section className="valueSection marketingContainer">
      <div className="valueCopy">
        <span className="eyebrow">START SIMPLE. GROW WHEN YOU’RE READY.</span>
        <h2>A better home-care habit starts free.</h2>
        <p>Build your plan and see your schedule without entering a credit card. UpkeepCue Plus is available for <strong>$0.99 per month</strong> when you want the extra tools.</p>
        <div className="valueList">
          <span><b>✓</b> Unlimited maintenance reminders</span>
          <span><b>✓</b> Household sharing</span>
          <span><b>✓</b> Maintenance history and receipts</span>
          <span><b>✓</b> Smart home-care recommendations</span>
        </div>
      </div>
      <div className="signupCard">
        <span className="signupIcon" aria-hidden="true">⌂</span>
        <p className="signupLabel">YOUR PERSONAL HOME PLAN</p>
        <h2>Ready to make home care feel lighter?</h2>
        <p>Answer a few quick questions. UpkeepCue will take it from there.</p>
        <Link className="btn btnPrimary primaryCta" href="/auth">Build my free plan →</Link>
        <small>No credit card required.</small>
      </div>
    </section>

    <footer className="marketingFooter marketingContainer">
      <div className="brandWrap"><span className="brandMark" aria-hidden="true">⌂</span><span className="brand">UpkeepCue</span></div>
      <p>Less mental load. More confident home care.</p>
      <Link href="/auth">Sign in</Link>
    </footer>
  </main>;
}
