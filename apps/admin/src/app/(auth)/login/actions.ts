'use server';

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';

export async function loginAction(formData: FormData) {
  const token = formData.get('token') as string | null;

  if (!token || token.trim() === '') {
    return { error: 'Token is required.' };
  }

  const workerUrl =
    process.env['NEXT_PUBLIC_WORKER_URL'] ??
    'https://howlalert-worker.mrdemonwolf.workers.dev';

  let ok = false;
  try {
    const res = await fetch(`${workerUrl}/auth/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token }),
    });
    ok = res.ok;
  } catch {
    return { error: 'Could not reach the worker. Check NEXT_PUBLIC_WORKER_URL.' };
  }

  if (!ok) {
    return { error: 'Invalid admin token.' };
  }

  const cookieStore = await cookies();
  cookieStore.set('howlalert-session', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 7,
  });

  redirect('/dashboard');
}
