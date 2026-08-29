# `@domainry/runtime-client`

Transport-only client APIs for Builder-generated Domainry applications.

## Business event stream

```ts
import { RuntimeClient } from "@domainry/runtime-client";

const runtime = new RuntimeClient({
  apiBaseUrl: import.meta.env.VITE_RUNTIME_URL,
  workspaceId: session.workspaceId,
  surface: "business_workspace",
  getAccessToken: () => session.currentAccessToken(),
});

const events = runtime.subscribeBusinessEvents({
  objectKeys: ["customer", "order"],
  onEvent: (event) => {
    // Both refresh and resync are invalidation signals. Refetch through the
    // ordinary authorized Runtime record/report APIs; do not use SSE as data.
    queryClient.invalidateQueries({ queryKey: [session.workspaceId] });
  },
});

// Component/application teardown:
events.close();
```

The client uses authenticated `fetch` streaming rather than native
`EventSource`, because browsers cannot attach the required bearer header with
`EventSource`. It refreshes the token supplier on every reconnect, propagates
the last processed event ID and uses bounded
exponential reconnect delay. A `resync` event means bounded replay could not
close the gap; invalidate all affected read models.
