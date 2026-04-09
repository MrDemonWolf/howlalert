export default function LoginPage() {
  return (
    <main className="flex min-h-screen items-center justify-center">
      <div className="w-full max-w-sm rounded-xl border border-white/10 bg-white/5 p-8">
        <h1 className="mb-6 text-2xl font-bold text-white">HowlAlert</h1>
        <form className="flex flex-col gap-4">
          <div>
            <label className="mb-1 block text-sm text-white/60" htmlFor="secret">
              Admin Secret
            </label>
            <input
              id="secret"
              type="password"
              className="w-full rounded-lg border border-white/10 bg-white/5 px-4 py-2 text-white placeholder-white/30 focus:border-[var(--color-accent)] focus:outline-none"
              placeholder="Enter your admin secret"
            />
          </div>
          <button
            type="submit"
            className="rounded-lg bg-[var(--color-accent)] px-4 py-2 font-semibold text-[var(--color-bg)] transition hover:opacity-90"
          >
            Sign In
          </button>
        </form>
      </div>
    </main>
  );
}
