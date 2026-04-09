import { cookies } from 'next/headers';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const { token } = await req.json() as { token: string };

  if (!token) {
    return NextResponse.json({ error: 'Missing token' }, { status: 400 });
  }

  const cookieStore = await cookies();
  cookieStore.set('howlalert-session', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 7,
  });

  return NextResponse.json({ ok: true });
}

export async function DELETE() {
  const cookieStore = await cookies();
  cookieStore.delete('howlalert-session');
  return NextResponse.json({ ok: true });
}
