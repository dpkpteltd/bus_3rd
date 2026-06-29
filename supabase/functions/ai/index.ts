// Bus 3rd — AI proxy (Supabase Edge Function, Deno runtime)
//
// A thin, stateless function that holds the MiniMax API key server-side and
// turns it into four small comedy actions for the app. The app never sees the
// key. Nothing is stored: requests are forwarded to MiniMax and the result is
// returned. No database, no logging of user text.
//
// Deploy + secrets: see supabase/README.md.

// MiniMax uses an OpenAI-compatible chat-completions endpoint. All three are
// overridable via secrets so you can point at the right region / model without
// editing code.
const MINIMAX_API_URL =
  Deno.env.get('MINIMAX_API_URL') ?? 'https://api.minimax.io/v1/text/chatcompletion_v2';
const MINIMAX_API_KEY = Deno.env.get('MINIMAX_API_KEY') ?? '';
const MINIMAX_MODEL = Deno.env.get('MINIMAX_MODEL') ?? 'MiniMax-Text-01';

// The house voice.
const VOICE = `You write copy for "Bus 3rd", a PARODY comedy app that pretends to be a
bus-arrivals app where everything is deliberately, absurdly wrong. Tone: dry,
self-deprecating, kopitiam-uncle energy, gentle Singlish flavour ("lah", "sia",
"bo space", "chope"), fatalistic humour about buses that never come. Emojis are
welcome but sparing. Keep every line short and punchy.

HARD RULES:
- Everything is fictional. NEVER reference a real transit operator, real route
  numbers, real company, brand, or government agency. Invent fictional ones.
- No slurs, no targeting of real people, nothing hateful, sexual, or genuinely
  mean. Punch at the situation (late buses, commuting despair), never at people.
- Stay PG-13. This is a joke app in the Entertainment category.`;

const CORS = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'POST, OPTIONS',
  'access-control-allow-headers': 'authorization, x-client-info, apikey, content-type',
};

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'content-type': 'application/json', ...CORS },
  });
}

// --- MiniMax call -------------------------------------------------------------

interface ChatMsg {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

async function callMiniMax(messages: ChatMsg[], maxTokens = 1024): Promise<string> {
  const res = await fetch(MINIMAX_API_URL, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${MINIMAX_API_KEY}`,
    },
    body: JSON.stringify({
      model: MINIMAX_MODEL,
      messages,
      max_tokens: maxTokens,
      temperature: 1.0,
    }),
  });

  if (!res.ok) throw new Error(`minimax ${res.status}: ${await res.text()}`);

  const data = (await res.json()) as {
    base_resp?: { status_code?: number; status_msg?: string };
    choices?: Array<{ message?: { content?: string } }>;
  };
  // MiniMax signals API-level errors in base_resp even on HTTP 200.
  if (data.base_resp && data.base_resp.status_code && data.base_resp.status_code !== 0) {
    throw new Error(`minimax base_resp ${data.base_resp.status_code}: ${data.base_resp.status_msg}`);
  }
  const content = data.choices?.[0]?.message?.content ?? '';
  if (!content.trim()) throw new Error('minimax empty content');
  return content;
}

// Tolerant JSON extraction: strips ``` fences and grabs the outermost object so
// a stray sentence around the JSON doesn't break us.
function extractJson<T>(text: string): T {
  let s = text.trim();
  if (s.startsWith('```')) s = s.replace(/^```(?:json)?/i, '').replace(/```$/, '').trim();
  if (!s.startsWith('{')) {
    const a = s.indexOf('{');
    const b = s.lastIndexOf('}');
    if (a >= 0 && b > a) s = s.slice(a, b + 1);
  }
  return JSON.parse(s) as T;
}

async function callJson<T>(system: string, user: string, maxTokens = 1024): Promise<T> {
  const text = await callMiniMax(
    [
      { role: 'system', content: system },
      { role: 'user', content: `${user}\n\nRespond with ONLY a JSON object. No prose, no markdown fences.` },
    ],
    maxTokens,
  );
  return extractJson<T>(text);
}

// --- Actions ------------------------------------------------------------------

const GAG_PROMPTS: Record<string, string> = {
  arrival:
    'Generate fake bus arrivals as {"items":[{"dest","verdict","sub","times"}]}. ' +
    'dest = an absurd fictional destination ("Eventually", "Cancelled (vibes)"). ' +
    'verdict = a short status tag ("2 min (lies)", "Avoid lah"). sub = a one-line ' +
    'excuse. times = a tiny string ("Arr", "—", "12 28 51", "Gone").',
  review:
    'Generate fake app-store reviews as {"items":[{"initials","name","stars","quote"}]}. ' +
    'initials = 2-3 letters. name = like "Auntie Doris, 61". stars = integer 1-5 ' +
    '(mostly low). quote = a funny one-to-two sentence review.',
  map:
    'Generate short "live map" captions as {"items":["..."]} for a bus doing absurd ' +
    'things ("Recalculating… into the sea 🌊"). One short line each, emoji optional.',
  prank:
    'Generate fake push notifications as {"items":[{"title","body"}]}. title = short ' +
    '("Your bus update"). body = a funny one-liner ("Your bus went home early 🏠").',
  late:
    'Generate "how late will you be" predictions as {"items":[{"mins","confidence","note"}]}. ' +
    'mins = a tiny string ("37", "lol", "−%"). confidence = a joke value ("0%", "none"). ' +
    'note = a short jab.',
  feed:
    'Generate "live service update" feed lines as {"items":["..."]} for a transit ' +
    'breakdown the operator is clearly not fixing ("Update: the fault has developed a ' +
    'fault."). One short line each.',
};

async function handleGags(payload: any): Promise<Response> {
  const kind = String(payload?.kind ?? '');
  const count = Math.min(Math.max(parseInt(payload?.count ?? '6', 10) || 6, 1), 12);
  const prompt = GAG_PROMPTS[kind];
  if (!prompt) return json({ error: `unknown kind: ${kind}` }, 400);

  const data = await callJson<{ items: unknown[] }>(VOICE, `${prompt}\n\nReturn exactly ${count} items.`);
  return json({ items: Array.isArray(data.items) ? data.items : [] });
}

async function handleUncle(payload: any): Promise<Response> {
  const history: Array<{ role: string; text: string }> = Array.isArray(payload?.messages)
    ? payload.messages
    : [];
  const turns: ChatMsg[] = history
    .slice(-12)
    .filter((m) => m && typeof m.text === 'string' && m.text.trim())
    .map((m) => ({
      role: m.role === 'assistant' ? ('assistant' as const) : ('user' as const),
      content: String(m.text).slice(0, 800),
    }));
  if (turns.length === 0 || turns[0].role !== 'user') {
    return json({ error: 'messages must start with a user turn' }, 400);
  }

  const text = await callMiniMax(
    [
      {
        role: 'system',
        content:
          VOICE +
          '\n\nYou ARE the bus uncle: the gruff, unbothered, seen-it-all driver/inspector ' +
          'of Bus 3rd. The user is a stranded commuter. Reply in character — terse, ' +
          'fatalistic, secretly fond of them. 1-3 sentences. Never break character, ' +
          'never admit you are an AI, never give real transit info.',
      },
      ...turns,
    ],
    400,
  );
  return json({ text: text.trim() });
}

async function handleRoast(payload: any): Promise<Response> {
  const destination = String(payload?.destination ?? '').slice(0, 120).trim();
  if (!destination) return json({ error: 'destination required' }, 400);

  const data = await callJson<Record<string, string>>(
    VOICE,
    `A commuter wants to get to: "${destination}". Roast their commute. Return ` +
      '{"minutesLate","confidence","verdict","note","prank"}. minutesLate = a tiny ' +
      'absurd string ("47", "∞", "lol"). confidence = a joke confidence ("0%", "none"). ' +
      'verdict = a short brutal tag. note = a one-line forecast. prank = a fake ' +
      'notification body about this trip.',
    500,
  );
  return json(data);
}

async function handleCertificate(payload: any): Promise<Response> {
  const seed = String(payload?.seed ?? '').slice(0, 200);
  const data = await callJson<Record<string, string>>(
    VOICE,
    'Write a tongue-in-cheek "certificate of inner peace" for someone who has given up ' +
      'waiting for the bus and chosen serenity. Return {"title","body","stat1Label",' +
      '"stat1Value","stat2Label","stat2Value"}. title = short and triumphant. body = 1-2 ' +
      'warm, absurd sentences congratulating them. stat rows = two funny stats ' +
      '(e.g. "Buses missed today"/"4", "Minutes you will never get back"/"∞").' +
      (seed ? `\n\nContext: ${seed}` : ''),
    400,
  );
  return json(data);
}

const ACTIONS: Record<string, (payload: any) => Promise<Response>> = {
  gags: handleGags,
  uncle: handleUncle,
  roast: handleRoast,
  certificate: handleCertificate,
};

// --- Entry --------------------------------------------------------------------

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return json({ error: 'method not allowed' }, 405);
  if (!MINIMAX_API_KEY) return json({ error: 'server not configured' }, 500);

  let payload: any;
  try {
    payload = await req.json();
  } catch {
    payload = {};
  }

  const action = String(payload?.action ?? '');
  const handler = ACTIONS[action];
  if (!handler) return json({ error: `unknown action: ${action}` }, 400);

  try {
    return await handler(payload);
  } catch (err) {
    // 502 → the app treats it as "AI unavailable" and falls back on-device.
    return json({ error: 'ai unavailable', detail: String(err).slice(0, 200) }, 502);
  }
});
