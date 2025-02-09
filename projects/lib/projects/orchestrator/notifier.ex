defmodule ProjectsApi.Orchestrator.Notifier do
  @moduledoc """
  Notifier module for the Orchestrator server. It is responsible
  for sending notifications to the clients (websockets) about the
  processing status of the projects.
  """
  require Logger

  def notify_project_fully_finished(project_id) do
    Logger.info("Project with id #{project_id} has been fully processed")
  end

  def notify_project_step_finished(project_id) do
    Logger.info("Project with id #{project_id} has finished processing a step")
  end
end
