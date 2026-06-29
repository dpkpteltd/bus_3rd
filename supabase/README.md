# Bus 3rd — AI proxy (Supabase Edge Function + MiniMax)

A thin, **stateless** Edge Function that sits between the app and the **MiniMax**
LLM API. It holds the MiniMax key server-side (the app never ships a key),
exposes one function with four actions, and stores nothing — each request is
forwarded to MiniMax and the result returned.

## One function, four actions

`POST /functions/v1/ai` with a JSON body `{ "action": "...", ... }`:

| action        | extra body                          | returns |
| ------------- | ----------------------------------- | ------- |
| `gags`        | `{ kind, count }`                   | `{ items: [...] }` (shape depends on `kind`) |
| `uncle`       | `{ messages: [{role, text}, ...] }` | `{ text }` |
| `roast`       | `{ destination }`                   | `{ minutesLate, confidence, verdict, note, prank }` |
| `certificate` | `{ seed? }`                         | `{ title, body, stat1Label, stat1Value, stat2Label, stat2Value }` |

`kind` ∈ `arrival | review | map | prank | late | feed`.

## LLM: MiniMax

Calls MiniMax's OpenAI-compatible chat-completions endpoint. All three knobs are
**secrets**, so you can switch region/model without editing code:

| Secret           | Default                                                   |
| ---------------- | -------------------------------------------------------- |
| `MINIMAX_API_KEY`| _(required)_                                             |
| `MINIMAX_API_URL`| `https://api.minimax.io/v1/text/chatcompletion_v2`       |
| `MINIMAX_MODEL`  | `MiniMax-Text-01`                                         |

> Set `MINIMAX_MODEL` to whatever your MiniMax account actually has access to,
> and `MINIMAX_API_URL` to your region's endpoint. Structured replies are coaxed
> via prompt + tolerant JSON extraction (no provider-specific JSON-schema mode),
> so this works on any OpenAI-compatible MiniMax endpoint.

## Deploy

```bash
# from the repo root
supabase login                      # one-time
supabase link --project-ref <your-project-ref>

# set secrets (never commit these)
supabase secrets set MINIMAX_API_KEY=sk-...
# optional overrides:
# supabase secrets set MINIMAX_MODEL=abab6.5s-chat
# supabase secrets set MINIMAX_API_URL=https://api.minimaxi.com/v1/text/chatcompletion_v2

supabase functions deploy ai
```

The function lives at:
`https://<project-ref>.supabase.co/functions/v1/ai`

## Auth

The function is protected by Supabase's gateway, which requires the project's
**anon key** (a publishable JWT — safe to ship in a client app). The app sends it
as both the `apikey` and `Authorization: Bearer <anon>` headers. The MiniMax key
stays in function secrets and never reaches the client.

> The anon key gates access but is public, so it's not abuse-proof. For
> production add rate limiting (e.g. a per-IP counter in a Postgres table, or
> Supabase's built-in limits) before shipping widely.

## Wire it into the app

Pass your project URL + anon key at build time so they stay out of source control:

```bash
flutter run \
  --dart-define=BUS3RD_SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=BUS3RD_SUPABASE_ANON_KEY=<your anon key>
```

## Local dev

```bash
supabase functions serve ai --env-file ./supabase/.env.local
# .env.local holds MINIMAX_API_KEY=... etc. (gitignored)
```

## Notes

- **No logging of user text.** The function forwards and returns; it does not persist.
- A MiniMax error or any upstream failure returns `502`, which the app treats as
  "AI unavailable" and falls back to on-device generation.
