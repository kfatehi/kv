# http://elixir-lang.org/getting-started/mix-otp/genserver.html#testing-a-genserver
defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  doctest KV.Registry

  setup do
    {:ok, registry} = KV.Registry.start_link
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "can be stopped", %{registry: registry} do
    assert Process.alive?(registry)
    :ok = KV.Registry.stop(registry)
    refute Process.alive?(registry)
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
