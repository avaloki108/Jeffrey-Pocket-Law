import {genkit, z} from "genkit";
import {googleAI} from "@genkit-ai/google-genai";
import {onCallGenkit} from "firebase-functions/https";
import {defineSecret} from "firebase-functions/params";
import {enableFirebaseTelemetry} from "@genkit-ai/firebase";

enableFirebaseTelemetry();

const apiKey = defineSecret("GOOGLE_GENAI_API_KEY");

const ai = genkit({
  plugins: [googleAI()],
});

const menuSuggestionFlow = ai.defineFlow(
  {
    name: "menuSuggestionFlow",
    inputSchema: z
      .string()
      .describe("A restaurant theme")
      .default("seafood"),
    outputSchema: z.string(),
    streamSchema: z.string(),
  },
  async (
    subject: string,
    {sendChunk}: {sendChunk: (text: string) => void}
  ) => {
    const prompt =
      `Suggest an item for the menu of a ${subject} themed restaurant`;
    const {response, stream} = ai.generateStream({
      model: googleAI.model("gemini-2.5-flash"),
      prompt,
      config: {temperature: 1},
    });

    for await (const chunk of stream) {
      sendChunk(chunk.text);
    }

    return (await response).text;
  }
);

export const menuSuggestion = onCallGenkit(
  {
    secrets: [apiKey],
    // authPolicy: hasClaim("email_verified"),
  },
  menuSuggestionFlow
);
