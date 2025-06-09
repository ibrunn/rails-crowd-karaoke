# app/controllers/concerns/stage_routing.rb
module StageRouting
  extend ActiveSupport::Concern

  def get_stage_destination(stage, role, session)
    # Normalize to float for consistent comparison with database
    normalized_stage = stage.to_f

    destinations = {
      1.0 => {
        host: green_room_host_path(session.uuid),
        guest: green_room_guest_path(session.uuid)
      },
      2.0 => {
        host: genre_start_path(session.uuid),
        guest: genre_start_path(session.uuid)
      },
      3.0 => {
        host: genre_stats_path(session.uuid),
        guest: new_genre_votes_path(session.uuid)
      },
      35.0 => {
        host: genre_result_path(session.uuid),
        guest: genre_result_path(session.uuid)
      },
      4.0 => {
        host: song_start_path(session.uuid),
        guest: song_start_path(session.uuid)
      },
      5.0 => {
        host: song_stats_path(session.uuid),
        guest: new_song_votes_path(session.uuid)
      },
      55.0 => {
        host: song_result_path(session.uuid),
        guest: song_result_path(session.uuid)
      },
      6.0 => {
        host: sing_start_path(session.uuid),
        guest: sing_start_path(session.uuid)
      },
      7.0 => {
        host: sing_end_path(session.uuid),
        guest: sing_end_path(session.uuid)
      },
      8.0 => {
        host: sing_end_path(session.uuid),
        guest: sing_end_path(session.uuid)
      }
    }

    destinations[normalized_stage]&.[](role) || root_path
  end
end
