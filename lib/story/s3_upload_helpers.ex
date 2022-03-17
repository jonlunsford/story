defmodule Story.S3UploadHelpers do
  def get_image_url(socket, upload_key \\ :avatar) do
    Phoenix.LiveView.consume_uploaded_entries(socket, upload_key, fn %{key: key, url: url}, _entry ->
      if key do
        {:ok, "#{url}/#{key}"}
      else
        {:ok, nil}
      end
    end)
    |> List.first()
  end

  def presign_upload(entry, socket, upload_key \\ :avatar) do
    uploads = socket.assigns.uploads
    bucket = System.fetch_env!("AWS_BUCKET")
    key = "public/#{entry.uuid}-#{entry.client_name}"

    config = %{
      region: System.fetch_env!("AWS_REGION"),
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: Map.get(uploads, upload_key).max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: "https://#{bucket}.s3-#{config.region}.amazonaws.com",
      fields: fields
    }

    {:ok, meta, socket}
  end
end
