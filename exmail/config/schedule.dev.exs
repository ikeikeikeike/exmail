use Mix.Config

config :quantum, :exmail,
  cron: [
    cleanup_files: [
      schedule: "* * * * *",
      task: "Exmail.Tasks.Cleanup.unses_files",
      args: []
    ],
    aggs_tracks_perform: [
      schedule: "@hourly",
      task: "Exmail.Tasks.AggsTracks.perform",
      args: []
    ]
  ]
