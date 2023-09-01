let url = "https://sqs.us-east-1.amazonaws.com/992642541356/test_queue"

let send_sqs capnp_data =
  let encBase64 = Base64.encode_exn capnp_data in

  let temp_file_name = "temp_aws.text" in

  let oc = open_out temp_file_name in
  Printf.fprintf oc "%s" encBase64;
  close_out oc;

  let command =
    "aws sqs send-message --queue-url " ^ url ^ " --message-body file://"
    ^ temp_file_name
  in

  Sys.command command

