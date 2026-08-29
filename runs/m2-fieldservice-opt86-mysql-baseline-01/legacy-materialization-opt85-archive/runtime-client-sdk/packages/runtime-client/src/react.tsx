import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import {
  useMutation,
  useInfiniteQuery,
  useQuery,
  useQueryClient,
  type QueryClient,
  type UseMutationOptions,
} from '@tanstack/react-query'
import {
  RuntimeClient,
  RuntimeSessionStore,
  type RuntimeRecordQuery,
  type RuntimeAuthResponse,
	 type RuntimeNotificationQuery,
  type RuntimeSession,
} from './index'

export function runtimeReadModelRoot(client: RuntimeClient) {
  return ['runtime-business', client.workspaceId, client.surface] as const
}

export function runtimeRecordsQueryKey(
  client: RuntimeClient,
  objectKey: string,
  query: RuntimeRecordQuery = {},
) {
  return [...runtimeReadModelRoot(client), 'records', objectKey, query] as const
}

export function runtimeRecordQueryKey(
  client: RuntimeClient,
  objectKey: string,
  recordID: string,
) {
  return [...runtimeReadModelRoot(client), 'record', objectKey, recordID] as const
}

export function runtimeReportQueryKey(client: RuntimeClient, reportKey: string) {
  return [...runtimeReadModelRoot(client), 'report', reportKey] as const
}

export function runtimeActionsQueryKey(client: RuntimeClient, objectKey: string) {
  return [...runtimeReadModelRoot(client), 'actions', objectKey] as const
}

export function runtimeNotificationsQueryKey(
  client: RuntimeClient,
  query: RuntimeNotificationQuery = {},
) {
  return [...runtimeReadModelRoot(client), 'notifications', query] as const
}

export function runtimeNotificationFacetsQueryKey(
  client: RuntimeClient,
  query: RuntimeNotificationQuery = {},
) {
  return [...runtimeReadModelRoot(client), 'notification-facets', query] as const
}

export function runtimeNotificationUnreadQueryKey(client: RuntimeClient) {
  return [...runtimeReadModelRoot(client), 'notification-unread'] as const
}

export interface RuntimeReadModelInvalidation {
  all?: boolean
  objectKeys?: readonly string[]
  reportKeys?: readonly string[]
}

export async function invalidateRuntimeReadModels(
  queryClient: QueryClient,
  client: RuntimeClient,
  invalidation: RuntimeReadModelInvalidation = { all: true },
) {
  if (invalidation.all !== false) {
    await queryClient.invalidateQueries({ queryKey: runtimeReadModelRoot(client) })
    return
  }
  await Promise.all([
    ...(invalidation.objectKeys ?? []).map((objectKey) =>
      queryClient.invalidateQueries({
        queryKey: [...runtimeReadModelRoot(client), 'records', objectKey],
      })),
    ...(invalidation.reportKeys ?? []).map((reportKey) =>
      queryClient.invalidateQueries({
        queryKey: runtimeReportQueryKey(client, reportKey),
      })),
  ])
}

export function useRuntimeRecords(
  client: RuntimeClient,
  objectKey: string,
  query: RuntimeRecordQuery = {},
  options: { enabled?: boolean } = {},
) {
  return useQuery({
    queryKey: runtimeRecordsQueryKey(client, objectKey, query),
    queryFn: () => client.queryRecords(objectKey, query),
    enabled: options.enabled ?? true,
  })
}

export function useRuntimeRecord(
  client: RuntimeClient,
  objectKey: string,
  recordID: string,
  options: { enabled?: boolean } = {},
) {
  return useQuery({
    queryKey: runtimeRecordQueryKey(client, objectKey, recordID),
    queryFn: () => client.getRecord(objectKey, recordID),
    enabled: (options.enabled ?? true) && Boolean(recordID),
  })
}

export function useRuntimeActions(
  client: RuntimeClient,
  objectKey: string,
  options: { enabled?: boolean } = {},
) {
  return useQuery({
    queryKey: runtimeActionsQueryKey(client, objectKey),
    queryFn: () => client.listActions(objectKey),
    enabled: options.enabled ?? true,
  })
}

export function useRuntimeReport(
  client: RuntimeClient,
  reportKey: string,
  options: { enabled?: boolean; mode?: 'realtime' | 'snapshot' } = {},
) {
  return useQuery({
    queryKey: [...runtimeReportQueryKey(client, reportKey), options.mode ?? 'realtime'],
    queryFn: () => client.getReportSummary(reportKey, { mode: options.mode }),
    enabled: options.enabled ?? true,
  })
}

export function useRuntimeNotifications(
  client: RuntimeClient,
  query: RuntimeNotificationQuery = {},
  options: { enabled?: boolean } = {},
) {
  return useQuery({
    queryKey: runtimeNotificationsQueryKey(client, query),
    queryFn: () => client.listNotifications(query),
    enabled: options.enabled ?? true,
  })
}

export function useRuntimeInfiniteNotifications(
  client: RuntimeClient,
  query: Omit<RuntimeNotificationQuery, 'cursor'> = {},
  options: { enabled?: boolean } = {},
) {
  return useInfiniteQuery({
    queryKey: [...runtimeNotificationsQueryKey(client, query), 'infinite'],
    initialPageParam: '',
    queryFn: ({ pageParam }) => client.listNotifications({ ...query, cursor: pageParam || undefined }),
    getNextPageParam: (page) => page.has_more ? page.next_cursor : undefined,
    enabled: options.enabled ?? true,
  })
}

export function useRuntimeNotificationFacets(
  client: RuntimeClient,
  query: RuntimeNotificationQuery = {},
  options: { enabled?: boolean } = {},
) {
  return useQuery({
    queryKey: runtimeNotificationFacetsQueryKey(client, query),
    queryFn: () => client.notificationFacets(query),
    enabled: options.enabled ?? true,
  })
}

export function useRuntimeNotificationUnreadCount(
  client: RuntimeClient,
  options: { enabled?: boolean; refetchInterval?: number | false } = {},
) {
  return useQuery({
    queryKey: runtimeNotificationUnreadQueryKey(client),
    queryFn: () => client.notificationUnreadCount(),
    enabled: options.enabled ?? true,
    refetchInterval: options.refetchInterval ?? 30_000,
  })
}

export function useRuntimeNotificationSync(
  client: RuntimeClient,
  options: { enabled?: boolean } = {},
) {
  const queryClient = useQueryClient()
  const enabled = options.enabled ?? true
  useEffect(() => {
    if (!enabled) return
    return client.subscribeNotificationSync(() => {
      void Promise.all([
        queryClient.invalidateQueries({ queryKey: [...runtimeReadModelRoot(client), 'notifications'] }),
        queryClient.invalidateQueries({ queryKey: [...runtimeReadModelRoot(client), 'notification-facets'] }),
        queryClient.invalidateQueries({ queryKey: runtimeNotificationUnreadQueryKey(client) }),
      ])
    })
  }, [client, enabled, queryClient])
}

export function useRuntimeNotificationSavedViews(
  client: RuntimeClient,
  options: { enabled?: boolean } = {},
) {
  return useQuery({
    queryKey: [...runtimeReadModelRoot(client), 'notification-saved-views'],
    queryFn: () => client.listNotificationSavedViews(),
    enabled: options.enabled ?? true,
  })
}

export function useRuntimeNotificationSavedViewMutation<TVariables>(
  client: RuntimeClient,
  mutationFn: (variables: TVariables) => Promise<unknown>,
) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: [...runtimeReadModelRoot(client), 'notification-saved-views'] })
    },
  })
}

export function useRuntimeNotificationMutation<TVariables>(
  client: RuntimeClient,
  mutationFn: (variables: TVariables) => Promise<unknown>,
) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn,
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: [...runtimeReadModelRoot(client), 'notifications'] }),
        queryClient.invalidateQueries({ queryKey: [...runtimeReadModelRoot(client), 'notification-facets'] }),
        queryClient.invalidateQueries({ queryKey: runtimeNotificationUnreadQueryKey(client) }),
      ])
    },
  })
}

export function useRuntimeMutation<TData, TVariables>(
  client: RuntimeClient,
  mutationFn: (variables: TVariables) => Promise<TData>,
  options: Omit<UseMutationOptions<TData, Error, TVariables>, 'mutationFn' | 'onSuccess'> & {
    invalidation?: RuntimeReadModelInvalidation | ((data: TData, variables: TVariables) => RuntimeReadModelInvalidation)
    onSuccess?: (data: TData, variables: TVariables) => void | Promise<void>
  } = {},
) {
  const queryClient = useQueryClient()
  const { invalidation = { all: true }, onSuccess, ...mutationOptions } = options
  return useMutation({
    ...mutationOptions,
    mutationFn,
    onSuccess: async (data, variables) => {
      const target = typeof invalidation === 'function'
        ? invalidation(data, variables)
        : invalidation
      await invalidateRuntimeReadModels(queryClient, client, target)
      await onSuccess?.(data, variables)
    },
  })
}

const REFRESH_LEEWAY_MS = 60 * 1000

export interface RuntimeAuthContextValue {
  session: RuntimeSession | null
  login: (
    username: string,
    password: string,
    options?: { remember?: boolean },
  ) => Promise<RuntimeSession>
  refreshSession: () => Promise<RuntimeSession | null>
  logout: () => Promise<void>
}

const RuntimeAuthContext = createContext<RuntimeAuthContextValue | null>(null)

function sessionFromRuntime(
  response: RuntimeAuthResponse,
  remember: boolean,
  permissions: string[] = [],
): RuntimeSession {
  return {
    username: response.user.email || response.user.id,
    displayName: response.user.name || response.user.id,
    loginAt: new Date().toISOString(),
    roleId: response.default_role,
    accessToken: response.access_token,
    refreshToken: response.refresh_token,
    expiresAt: response.expires_at,
    remember,
    user: response.user,
    roles: response.roles,
    permissions,
  }
}

export function RuntimeAuthProvider({
  children,
  client,
  store,
}: {
  children: ReactNode
  client: RuntimeClient
  store: RuntimeSessionStore
}) {
  const [session, setSession] = useState<RuntimeSession | null>(() => store.read())
  const queryClient = useQueryClient()

  const login = useCallback(
    async (username: string, password: string, options?: { remember?: boolean }) => {
      const response = await client.login(username.trim(), password)
      const remember = options?.remember ?? true
      const me = await client.me(response.access_token)
      const next = sessionFromRuntime(
        response,
        remember,
        me.permissions,
      )
      queryClient.clear()
      store.persist(next)
      setSession(next)
      return next
    },
    [client, queryClient, store],
  )

  const refreshSession = useCallback(async () => {
    if (!session) return null
    const response = await client.refresh(session.refreshToken)
    const me = await client.me(response.access_token)
    const next = sessionFromRuntime(
      response,
      session.remember,
      me.permissions,
    )
    next.loginAt = session.loginAt
    store.persist(next)
    setSession(next)
    return next
  }, [client, session, store])

  const logout = useCallback(async () => {
    const current = store.read()
    try {
      if (current?.refreshToken) await client.logout(current.refreshToken)
    } finally {
      store.clear()
      queryClient.clear()
      setSession(null)
    }
  }, [client, queryClient, store])

  useEffect(() => {
    const current = store.read()
    if (!current) return
    void client.me(current.accessToken)
      .then((me) => {
        const next: RuntimeSession = {
          ...current,
          username: me.user.email || me.user.id,
          displayName: me.user.name || me.user.id,
          roleId: me.default_role,
          user: me.user,
          roles: me.roles,
          permissions: me.permissions,
        }
        store.persist(next)
        setSession(next)
      })
      .catch(async () => {
        try {
          const response = await client.refresh(current.refreshToken)
          const me = await client.me(response.access_token)
          const next = sessionFromRuntime(
            response,
            current.remember,
            me.permissions,
          )
          next.loginAt = current.loginAt
          store.persist(next)
          setSession(next)
        } catch {
          store.clear()
          queryClient.clear()
          setSession(null)
        }
      })
  }, [client, queryClient, store])

  useEffect(() => {
    function syncPersistentSession(event: StorageEvent) {
      if (event.key !== store.storageKey || event.storageArea !== window.localStorage) return
      queryClient.clear()
      setSession(store.read())
    }
    window.addEventListener('storage', syncPersistentSession)
    return () => window.removeEventListener('storage', syncPersistentSession)
  }, [queryClient, store])

  useEffect(() => {
    if (!session) return
    const refreshIn = Math.max(
      0,
      Date.parse(session.expiresAt) - Date.now() - REFRESH_LEEWAY_MS,
    )
    const timer = window.setTimeout(() => {
      void refreshSession().catch(() => void logout())
    }, refreshIn)
    return () => window.clearTimeout(timer)
  }, [session, refreshSession, logout])

  const value = useMemo(
    () => ({ session, login, refreshSession, logout }),
    [session, login, refreshSession, logout],
  )
  return (
    <RuntimeAuthContext.Provider value={value}>
      {children}
    </RuntimeAuthContext.Provider>
  )
}

export function useRuntimeAuth(): RuntimeAuthContextValue {
  const context = useContext(RuntimeAuthContext)
  if (!context) {
    throw new Error('useRuntimeAuth must be used within RuntimeAuthProvider')
  }
  return context
}
