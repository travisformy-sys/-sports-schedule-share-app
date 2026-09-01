'use client';
import Link from 'next/link';
import {FormEvent,useState} from 'react';
import {createBrowserSupabase} from '../../lib/supabase/client';

export default function AuthPage(){
  const[email,setEmail]=useState('');const[message,setMessage]=useState('');const[busy,setBusy]=useState(false);
  async function submit(e:FormEvent){e.preventDefault();setBusy(true);setMessage('');try{const supabase=createBrowserSupabase();const{error}=await supabase.auth.signInWithOtp({email,options:{emailRedirectTo:`${window.location.origin}/dashboard`}});if(error)throw error;setMessage('Check your email — your secure HomeKeep sign-in link is on the way.')}catch(err){setMessage(err instanceof Error?err.message:'Unable to send sign-in link.')}finally{setBusy(false)}}
  return <main className="authShell">
    <Link href="/" className="brandWrap"><div className="brandMark">⌂</div><div className="brand">HomeKeep</div></Link>
    <section className="card authCard">
      <span className="badge">Secure password-free sign in</span>
      <h1 className="authTitle">Welcome home.</h1>
      <p className="muted" style={{lineHeight:1.55}}>Enter your email and we’ll send you a private sign-in link. No password to remember.</p>
      <form onSubmit={submit} className="grid" style={{marginTop:20}}>
        <label className="field">Email address<input className="input" type="email" autoComplete="email" required value={email} onChange={e=>setEmail(e.target.value)} placeholder="you@example.com"/></label>
        <button className="btn btnPrimary" disabled={busy}>{busy?'Sending…':'Continue with email'}</button>
      </form>
      {message&&<div className={message.startsWith('Check')?'message':'alert'}>{message}</div>}
      <div className="divider"/><p className="fine">By continuing, you’re creating or signing into your HomeKeep account. Your maintenance data is kept separate from other HomeKeep households.</p>
    </section>
  </main>
}
