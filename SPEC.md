# scig

A utility that generates a HTTP server from a high-level device description file.

## What is `scig`?
Many serial devices follow a simple plaintext command-response pattern. Manually writing implementations for these devices can be repetitive. Especially when the same device requires a library, server, and CLI implementation to be written. `scig` is a utility that uses a high-level, declarative device description file (`<input_file>`) to automatically generate those outputs.

The long-term goal of the `scig` project is to establish a stable input representation from which a wide variety of output implementations can be generated. However, as a proof of concept, this first implementation only generates a HTTP web service for controlling the device.

## Usage

```bash
$ scig [--help] <command> [<args>]
$ scig start [--help]
$ scig start <process_type> [--help] [<args>]
$ scig start http [--help] [--port] <com_port> <input_file>
```

## Examples

```bash
# Shows the usage and <command>s listing
$ scig
	
# Shows scig general help
$ scig --help

# Shows help for `scig start`
$ scig start --help

# Shows help for `scig start http`
$ scig start http --help

# Starts a scig http server for controlling
# the device (windows COM port style)
$ scig start http COM4 input-file

# Starts a http server for controlling
# the device (linux serial port style)
$ scig start http /dev/ttyS0 input-file

# Starts a scig http server on port 80
# for controlling the device
$ scig start http --port 80 /dev/ttyS0 input-file
```

## `scig`

- `scig` is the application's name
- `scig` is used through a standard command-line interface
- Named arguments to `scig`'s command-line interface begin with one or two dashes (e.g. `-h` and `--help`)
- Unnamed arguments passed to `scig` change its context. For example, passing "`start`" to `scig` will change its context such that it then accepts further arguments related to `start`ing a process.
- The effect of arguments passed to `scig` depends on `scig`'s current context. For example, only providing the `--help` option to `scig` will show `scig`'s general help page; however, passing both `start` and `--help` will show the more specific `scig start` help page.
- In this initial implementation, `scig` only supports changing its context *via* a single unnamed argument—`start`. Later versions of `scig` will support other subcommands (e.g. `compile` or `generate`)
- Named options (e.g. `--port`) are collected by `scig` regardless of their location in a `scig`'s argument list. For example, "`scig --help start`" will exhibit the same behavior as "`scig start --help`". Likewise, "`scig --port 80 start http`" will exhibit the same behavior as "`scig start http --port 80`".
- If insufficient or invalid arguments are supplied to a `scig` call then the `scig` process will write usage instructions / error messages to the standard error (`STDERR`) and return an error code of `1` (general error)
- Regardless of context, specifying unrecognized arguments (for example, `--foo=bar`) will result in `scig` writing an error message to the standard error (`STDERR`) followed by terminating with a return code of `1` (general error)

## `scig` Command-Line Options
These command line options are available from the base context of `scig`. That is, the context of `scig` when no `command` unnamed arguments are provided to it.

### `-h, --help`
Show the general help documentation for `scig`. Contains a usage statement followed by a list of arguments for the base context, followed by a list of `command`s and their purpose, followed by some example usage cases.

  - The help documentation will be written to the standard output (`STDOUT`)
  - After it has been written to the standard output, the `scig` process will exit with a return code of `0` (no error)

## `scig` `<command>`s
`scig` is composed of individual commands that each have their own command-specific options and behaviours. When calling `scig`, the name of the command is given (e.g. `scig start`) followed by command-specific options and arguments (e.g. `scig start http --port 80 /dev/ttyS0 input-file`). In this inital release, `scig` only supports the `start` command.

  - The first unnamed argument supplied to `scig` is assumed to be the name of a command
  - If the name is not recognized, `scig` shall print the following error message:

  > `scig: '$first_argument' is not a scig command. See 'scig --help'.`

  - (*cont.*) After printing the error message, the `scig` process shall exit with a return code of `1` (general error)

### `scig start`

- `scig start` is the syntax to start an ongoing `scig` processes such as a server or CLI client
- If an initialization error occurs, the `scig start` process will write error/feedback messages to the standard error (`STDERR`) followed by terminating with a return code of `1` (general error) 
- Once sucessfully initialized, a `scig start` session will continually run until it is explicitly stopped
- When started via a CLI, the `scig start` process will exit with a return code of `130` if exited using the `CTRL+C` key combination
- While running, the `scig start` process writes errors to the standard error (`STDERR`).
- What `scig start` writes to the standard output (`STDOUT`) depends on the type of process that was started. For example, `http` shall write a human-readable representation of any HTTP request the server's port recieves
- `<process_type>` is case-sensitive and, in this initial implementation only `http` is supported

### `scig start` Options

### `-h, --help`
Show the usage of the `scig start` command, options, and available subcommands (e.g. `http`).

 - The help argument behaves exactly as it does when `scig` is in its base context. The only difference is that the documentation shown is related to `scig start`, not `scig` as a whole

### `scig start` `<command>`s
In this initial release, the only supported command is `http`.

#### `http`
Starts a server that allows the device's details, commands, and documentation to be requested with standard http requests.

#### `http` Usage

    scig start http [--port=<port>] com_port input_file

#### `http` Options

##### `-h, --help`
*Optional*. Shows the `http` command's documentation, outlining its usage, options, and examples.

 - The help argument behaves exactly as it does when `scig` is in its base context. The only difference is that the documentation shown is related to `scig start http`, not the `scig` base context nor the `start` one.

##### `-p=<port>, --port=<port>`
*Required*. The TCP port that the `scig` http server should listen on.

  - `<port>` is checked and allocated during the initialization of `scig`
  - A malformed `<port>` will result in the following message being written to the standard error (`STDERR`):

  > `scig: The supplied port ($<port>) is not a valid. The port must be a number between 1-65535`.

  - (*cont.*) After writing that error message, the `scig` process will terminate with an exit code of `1` (general error)
  - The `<port>` is already in use by another process will result in the following message being written to the standard error (`STDERR`):

 > `scig: The supplied port ($<port>) is currently in use by another process: $process_details`

  - (*cont.*) After writing the error message, the `scig` process will be terminated with an error code of `1` (general error)
  - The `scig` process having insufficient privellages to open `<port>` will result in the following message being written to the standard error (`STDERR`):

  > `scig: Cannot open the supplied port ($<port>). Access is denied.`

  - (*cont.*) After writing that error message, the `scig` process will terminate with an error code of `1` (general error)

#### `com_port`

*Required*. The port that the serial device is connected to (e.g. `COM1` on Windows systems or `/dev/ttyS0` on Linux systems).

  - `com_port` is checked during the initialization of `scig`
  - A malformed `com_port` value will result in the following error message being written to the standard output (`STDERR`):

  > `scig: The supplied serial port ($com_port) is not a valid serial port identifier. $platform_dependant_text`

  - (*cont.*) The error message will contain platform-dependant messages because operating systems have differing methods of handling com port (e.g. `COMX` in windows, device files in unix). After writing the error message, the `scig` process will terminate with an error code of `1` (general error)
  - A valid, but non-existient, `com_port` value will result in the following error messge being written to the standard output (`STDERR`)

  > `scig: The supplied serial port ($com_port) but does not exist.`

  - (*cont.*) After writing the error message, the `scig` process will terminate with an error code of `1` (general error)
  - `scig` needs exclusive read/write access to `com_port`. If `com_port` is already being in use by another process then the following message will be written to the stadard error (`STDERR`):

  > `scig: The supplied serial port ($com_port) is already in use by another process ($process_details)`

  - (*cont.*) After writing the error message, the `scig` process will be terminated with an error code of `1` (general error)
  - The `scig` process having insufficient privellages to open `com_port` will result in the following message being written to the standard error (`STDERR`)

  > `scig: Cannot open the supplied serial port ($com_port). Access is denied.`

  - (*cont.*) After writing the error message, the `scig` process will terminated with an error code of `1` (general error)

##### `input_file`
*Required* the path to a `scig` serial device specification (`DEVICE_SPEC`)

  - A non-existient `input_file` path will result in the following error message being written to the standard output (`STDERR`):

  > `scig: $input_file: No such file or directory`

  - (*cont.*) After writing the error message, the `scig` process will terminate with an error code of `1` (general error)
  - `scig` requires non-exclusive read access to `input_file` at initialization time. If another process has locked `input_file` from read access then the following message will be written to the standard error (`STDERR`)

  > `scig: Cannot read $input_file. It is in use by another process ($process_information)

  - (*cont.*) After writing the error message, the `scig` process will terminate with an error code of `1` (general error)
  - If the `scig` process does not have sufficient privellages to read `input_file` then the following message will be written to the standard error (`STDERR`):

  > `scig: Cannot open the supplied serial port ($com_port). Access is denied.

  - (*cont.*) After writing the error message, the `scig` process will terminate with an error code of `1` (general error)
  - The `scig` process should open `input_file` with shared read access permissions
  - The `scig` process should release its handle to `input_file` once it has finished reading it. This is to facilicates scenarios in which many `scig` processes are booted from the same `input_file`
  - The general format of `input_file` is that it must be a text file that uses a standard encoding (UTF-8). If `input_file` does not have that general format then the following message will be written to the standard error (`STDERR`):

  > `scig: The format of $input_file is not recognized. input_file should be a plaintext file that uses a standard text encoding convention (e.g. utf-8)`

  - (*cont.*) After writing the error message, the `scig` process will terminate with an error code of `1` (general error)

  - The text content of `input_file` must follow the schema specified in `DEVICE_SPEC`. If it does not then the following error message with this general format will be written to the standard error (`STDERR`):

```
$input:$parse_error.line:$parse_error.column error: $parse_error.message
```

  - (*cont.*) One of these messages will be generated for each error encountered in `input_file`. After writing the error message, the `scig` process will terminate with an error code of `1` (general error)

## `DEVICE_SPEC`
`DEVICE_SPEC` is the most important aspect of `scig`. In it, the specification of a serial device is described declaratively. `scig` *should* be able to generate a wide variety of interfaces From `DEVICE_SPEC` (eventually).

`DEVICE_SPEC` is a *text* specification, not a *cli* specification because a `scig` library user may parse an in-memory string containing the `DEVICE_SPEC`. Because of that, the error messages described in this section should be handled according to the context. For example, as described above, the `scig` CLI shall write errors to the standard error followed by terminating with an exit code of `1`. A library implementation may throw an exception containing the applicable error message.

There are everal key points about the structure of `DEVICE_SPEC`:

 - The content of `DEVICE_SPEC` has a YAML-like structure. However, it cannot be guaranteed that `scig` supports all the features of the YAML specification
 - Comments within `DEVICE_SPEC` begin with a hash ( `#` ), can start anywhere on a line, and continue until the end of the line
 - Entries in `DEVICE_SPEC` are described as `key: value` pairs
 - `key`s are alphanumeric. Separate words within a `key` are separated as `camel_case`
 - Non-array `value`s span a single line. Multiline `value`s are not officially supported
 - Some `value`s, such as the the `value` for the `commands` key, have an array structure
 - Array elements are, like other entities, `key: value` pairs
 - Array items appear on a new line and are preceded by a dash ( `-` ). For example:

```yaml
an_array:
  - name: Item 1
    foo: bar
  - name: Item 2
    key: value
```

## `DEVICE_SPEC` Example

```yaml
# Comments begin with a hash

device:
  identifier: ika_ret_hotplate # This is also a comment
  name: IKA RET Hotplate
  # Optional: arbitrary information about the device
  metadata:
	manufacturer: IKA
	year_of_manufacture: 1992
	device_api_version: 3
	product_page_url: http://ika.com/ika-ret

# Unsupported keys are ignored by scig and allow
# the scig file to be augmented with additional
# data
an_unsupported_key: some_value 

connection:
  baud_rate: 9600
  parity: even
  data_bits: 7
  stop_bits: 1
  timeout: 200 ms 
  string_terminator: \r\n

commands:
  set_device_name:
    summary: Set the hotplate's name
	outgoing_command_format:
	  format: OUT_NAME $new_name
	  $new_name type: string
	  $new_name description: The new name of the device
	incoming_response_template:
	  template: (.+?) (.+?)
	  $1 type: string
	  $1 description: The device's previous name
	  $2 type: int
	  $2 description: The transaction id
	  
  get_device_name:
    summary: Get the hotplate's name
	outgoing_command_format:
	  format: IN_NAME
	incoming_response_template:
	  template: (\w+?) \d+
	  $1 type: string
	  $1 description: The device's name
```

### `DEVICE_SPEC "device:"` Keys
These keys describe the device. They only contain high-level information about the nature of the device (no technical details).

### `identifier: DEVICE_IDENTIFIER`
*Required*. A programmatic identifier for the device.

  - Valid `DEVICE_IDENTIFIER`s must begin with a standard alphabetical letter followed by alphanumeric characters. If it does not, then the following error message shall be issued:

  > `line:col: The supplied identifier, $DEVICE_IDENTIFIER, is invalid. The identifier must begin with a standard alphabetical letter (a-z) followed by alphanumeric characters. Words within the identifier should be separated by underscores. For example, "autosampler_9000"`

  - `DEVICE_IDENTIFIER` should be written in `camel_case`. Individual words within `DEVICE_IDENTIFIER` should be separated with underscores (e.g. `my_programattic_name`).
  - The case of alphabetical characters within `DEVICE_IDENTIFIER` is ignored. If `DEVICE_IDENTIFIER` contains uppercase characters, the following warning shall be issued:

  > `line:col: The supplied identifier, $PROGRAMMATIC_NAME, contains uppercase characters. This is not a problem; however, scig will ignore the case of characters within $PROGRAMMATIC_NAME. It is reccomended you use an all lower-case camel_case name. For example, "my_device", rather than "My_Device". "identifer:" is only used programatically. You can specify a case-sensitive name for the device in the "name:" field`
  
  - The absence of an `identifier:` key will result in the following error message being issued:
  
  >`line:col: device does not contain a "identifier" key. Scig requires an "identifer:" key to be present with a valid programmatic name for the device. For example, "identifier: nmr_barcode_reader"`

- `COMMAND_IDENTIFIER` cannot be an established programming keyword **TODO**

### `name: DEVICE_NAME`
*Required*. The name of the device.

  - `DEVICE_NAME` must contain at least one non-whitespace character. If it does not then the following error message shall be issued:

  > `line:col: The supplied name for the device is blank.

  - `DEVICE_NAME` cannot contain multiple lines. If it does, then the following error message shall be issued:

  > `line:col: The supplied name for the device contains newlines. The device name must span a single line`

  - Apart from the whitespace restrictions, `DEVICE_NAME` can contain any characters supported by the character set of the string. For example, chineese characters such as `NYI` shall be supported.
  - The absence of an `name:` key will result in the following error message being issued:
  > `device: does not contain a "name" key. Scig requires a "name:" key to be present with the name of the device as its value. For example, "name: NMR Barcode Reader"`

### `metadata: METADATA_KEY_VALUES`
*Optional*. Additional related metadata about the device.

  - Metadata is expressed as `key: value` pairs.
  - Metadata is guaranteed to have no reserved keys within it. Arbitrary `key: value` pairs can be put into the `metadata:` field without them being invalidated in later versions of `scig`.
  - The `metadata:` key is optional. Its absence shall be treated as "no metadata available"
  - If the `metadata:` key is present but no `key: value` pairs can be found within it then the following error shall be issued:

  > `line:col: A metadata key was specified but no values were found within it. "metadata:" is optional, and can be ommited if no metadata is available

  - If `METADATA_KEY_VALUES` are not `key: value` pairs (e.g. a string value was given) then the following error shall be issued:

  > `line:col: Invalid metadata key value. The metadata key should contain a set of key-value pairs`

  - If duplicate `key`'s are found in `METADATA_KEY_VALUES` then the following error shall be issued:

  > `line:col: A duplicate delcaration of $key was found in the metadata field`

### `image: DEVICE_IMAGE`
*Reserved*. `scig` shall produce a warning that this key is reserved and issues may be encountered with future versions of `scig` if it is used.

### `manufacturer: MANUFACTURER`
*Reserved*. `scig` shall produce a warning that this key is reserved and issues may be encountered with future versions of `scig` if it is used.

### `other_names: OTHER_NAMES`
*Reserved*. `scig` shall produce a warning that this key is reserved and issues may be encountered with future versions of `scig` if it is used.

### `DEVICE_SPEC "connection:"` Keys
These keys contain information about the physical connection to the device. In this initial implementation of `scig`, only `RS232` connections are supported.

### `baud_rate: BAUD_RATE`
*Required*. The baud rate of the connection in bits per second (bps).

  - If `BAUD_RATE` is not a positive integer then the following error shall be issued:

  > `line:col: Invalid baud rate. The baud rate is in bits per second and must be a positive integer. For example, "baud_rate: 9600"`

  - If the `baud_rate` key is absent, then the following error shall be issued:

  > `line:col: connection does not contain a "baud_rate" key. scig requires a baud_rate key with a valid value. For example, "baud_rate: 9600"

### `parity: PARITY (even|odd|none)`
*Required*. The parity of the connection.

  - `PARITY` is case-sensitive and must have a value of `even`, `odd`, or `none`. If `PARITY` is invalid, the following error shall be issued:

  > `line:col: Invalid value for parity ($PARITY). Supported values are 'even', 'odd', or 'none'. For example: "parity: even".

  - If the `parity:` key is absent, then the following error shall be issued:

  > `line:col: connection does not contain a "parity" key. scig requires a parity key with a value of 'even', 'odd', or 'none'. For example: "parity: even".

### `data_bits: DATA_BITS (1|2|3|4|5|6|7|8)`
*Required*. The number of data bits in a packet sent through the connection.

  - If `DATA_BITS` is not `1`, `2`, `3`, `4`, `5`, `6`, `7`, or `8` then the following error shall be issued:

  > `line:col: Invalid value for data_bits ($DATA_BITS). The value must be either '1', '2', '3', '4', '5', '6', or '8'. For example, "data_bits: 8".

  - If the `data_bits` key is absent then the following error shall be issued:

  > `line:col: connection does not contain a "data_bits" key. scig requires a data_bits key with a value of '1', '2', '3', '4', '5', '6', or '8'. For example, "data_bits: 8".

### `stop_bits: STOP_BITS (0|1|1.5|2)`
*Required*. The number of stop bits that terminate a data packet sent through the connection.

  - If `STOP_BITS` is not '0', '1', '1.5', or '2' then the following error shall be issued:

  > `line:col: Invalid value for stop_bits ($STOP_BITS). The value must be either 0, 1, 1.5, or 2. For example, "stop_bits: 1".

  - If the `stop_bits` key is absent then the following error shall be issued:

  > `line:col: connection does not contain a "stop_bits" key. scig requires a stop_bits key with a value of 1, 2, 3, or 4. For example, "stop_bits: 4".

### `timeout: TIMEOUT (N ms|s) (default: 20 ms)`
*Optional*. The maximum timespan a read/write operation through the connection can take before timing out.

  - If a `timeout:` key is not supplied, a default `TIMEOUT` of `20 ms` is used. If the default is used, `DEVICE_SPEC` linters shall issue the following advice:

  > `line:col connection does not contain a timeout value. scig will default to a timeout of "20 ms"; however, it is reccomended that you explicitly set a representative timeout value for the $DEVICE_NAME. For example: "timeout: 1 s"

  - If a `timeout:` key is supplied then `TIMEOUT` must have the form "`N` `unit`" where `N` is a positive integer and `unit` is either `ms` (milliseconds) or `s` (seconds). If the format of `TIMEOUT` is invalid then an error shall be issued:

> `line:col connection timeout ($TIMEOUT) is not a valid value. Timeouts must be specified as a positive integer followed by the time's unit of measure (either ms or s). For example, "timeout: 20 ms"`

### `string_terminator: TERMINATOR (\r\n|\n)`
*Required*. The characters that indicate the end of string send through the connection.

  - `TERMINATOR` shall be used to construct a string when reading signals from the device
  - `TERMINATOR` shall be appended to the end of any strings sent to the device
  - `TERMINATOR` must have a value of either `\r\n` or `\n`. If `TERMINATOR` is invalid then the following error shall be issued:

  > `line:col connection string_terminator ($TERMINATOR) is not a valid value. The string terminator must be either '\n' or '\r\n'. For example: "string_terminator: \n"`

  - If the `terminator:` key is absent then the following error shall be issued:

  > `line:col connection does not contain a "string_terminator" key. scig requires a string_terminator key with a value of '\n' or '\r\n'. For example, "string_terminator: \r\n"`

### `encoding: ENCODING`
*Reserved*. `scig` shall produce a warning that this key is reserved and issues may be encountered with future versions of `scig` if it is used.

### `handshake: HANDSHAKE`
*Reserved*. `scig` shall produce a warning that this key is reserved and issues may be encountered with future versions of `scig` if it is used.

### `DEVICE_SPEC commands:` Keys
*Optional* The `commands` key contains an array of `COMMAND_DESCRIPTION`s that describe, delcaratively, the possible commands that the device can recieve (via the connection).

`COMMAND_DESCRIPTION`s are a core part of the `DEVICE_SPEC` because they allow authors to specify the behavior of the device in a declarative, high-level way.

The `commands:` key has the following stucture:

```yaml
commands:
  COMMAND_IDENTIFIER:
    COMMAND_DESCRIPTION
  COMMAND_IDENTIFIER:
    COMMAND_DESCRIPTION
  .
  .
  .
```

  - `COMMAND_IDENTIFIER` must begin with a standard alphabetical letter followed by alphanumeric characters. If it does not, then the following error message shall be issued:

  > `line:col:` The supplied command identifier, $COMMAND_IDENTIFIER, is invalid. A command identifier must begin with a standard alphabetical letter (a-z) and can be followed by alphanumeric characters and underscores. Words within the command identifier should be separated by underscores. For example: "get_sample_list:"

  - `COMMAND_IDENTIFIER` should be written in `camel_case`. That is, individual words within `COMMAND_IDENTIFIER` should be seaprated with underscores (e.g. `foo_command`)
  - The case of alphabetical characters within `COMMAND_IDENTIFIER` are ignored. If `COMMAND_IDENTIFIER` contains uppercase characters, the following warning shall be issued:

  > `line:col: The supplied command identifier, $COMMAND_IDENTIFIER, contains uppercase characters. This is not a problem; however, scig will ignore the case of characters within $COMMAND_IDENTIFIER. It is reccomended you use an all lower-case camel_case name. For example, "my_device", rather than "My_Device". "identifer:" is only used programatically. You can specify a case-sensitive name for the device in the "name:" field`

  - `COMMAND_IDENTIFIER` cannot be an established programming keyword **TODO**

## `COMMAND_DESCRIPTION`
`COMMAND_DESCRIPTION` defines a command that the device can perform. Commands in this context are defined to be messages that the device can recieve and expected responses from the device. An example of a `COMMAND_DESCRIPTION` is:

```
summary: Set the hotplate's name
outgoing_message:
  has_format: OUT_NAME $new_name
  $new_name type: string
  $new_name description: The new name of the device
expected_response:
  follows_pattern: ^(.+?) (.+)$
  $1 identifier: old_name
  $1 description: The device's previous name
  $2 name: command_number
  $2 description: The command number of this set_device_name call
```

The following keys make up a `COMMAND_DESCRIPTION`:

### `summary: COMMAND_SUMMARY`
*Required*. A summary of the command's behavior.

  - `COMMAND_SUMMARY` is typically a one-sentence, readable description of the command.
  - `COMMAND_SUMMARY` can be any valid string; however, line breaks will be stripped from `COMMAND_SUMMARY` to produce a single-line string
  - `COMMAND_SUMMARY` must contain at least one non-whitespace character. If it does not, then the following error shall be issued:

  > `line:col` summary: must contain at least one non-whitespace character. The summary is typically a one-sentence, readable description of the command. For example: "summary: Get the name of the autosampler"

  - If the `summary:` key is absent from the `COMMAND_DESCRIPTION` then the following error shall be issued:

  > `line:col $COMMAND_IDENTIFIER must contain a "summary" key. The summary is typically a one-sentence, readable description of the command. For example: "summary: Get the name of the autosampler"`

### `description: COMMAND_DESCRIPTION`
*Reserved*. `scig` shall produce a warning that this key is reserved and issues may be encountered with future versions of `scig` if it is used.

### `outgoing_message: OUTGOING_MESSAGE`
*Required*. A specification of the message that will be sent to the device.

  - `OUTGOING_MESSAGE` describes the actual string that is sent to the device.
  - `OUTGOING_MESSAGE` follows the specification outlined in the "`OUTGOING_MESSAGE` Specification" (below). The specification describes any errors that `OUTGOING_MESSAGE` may contain (and the appropriate error message)
  - If the `outgoing_message:` key is absent from `COMMAND_DESCRIPTION` then the following error shall be issued:

  > `line:col $COMMAND_IDENTIFIER must contain an "ougoing_message" key. The outgoing_message key describes the string that will be sent to the $DEVICE_NAME.`

### `expected_response: nothing|ignore|EXPECTED_RESPONSE`
*Required*. The the expected response from the device after sending it the outgoing message.

  - If `nothing` is written as the expected response, then it is assumed that the device should not send a response to the `OUTGOING_MESSAGE`. In that case, recieving a response from the device after sending the `OUTGOING_MESSAGE` is considered to be a runtime error.
  - If `ignore` is written as the expected response, then it is assumed that, at runtime, the device shall send a message in response to the `OUTGOING_MESSAGE` but the implementation should do nothing with the message content. If the device does not send a response within the specified `timeout` period then a runtime timout error shall occur.
  - If an `EXPECTED_RESPONSE` is written as the expected response, then that shall be handled as outlined in the `EXPECTED_RESPONSE` specification (below).
  - `EXPECTED_RESPONSE` describes the expected structure of the string that is recieved from the device in response to the outgoing command.
  - `EXPECTED_RESPONSE` follows the specification outlined in the "`EXPECTED_RESPONSE` Specification" (below). The specification describes any errors that `EXPECTED_RESPONSE` may contain (and the appropriate error message).
  - If the `incoming_response_template:` key is absent from the `COMMAND_DESCRIPTION` then it is assumed that that device should not respond to the outgoing command

## `OUTGOING_MESSAGE` Specification
`OUTGOING_MESSAGE` describes the format of messages sent to the device.  It is engineered to handle both static commands that never change and commands that have some variance. An example of a static command would be:

```
    outgoing_message:
		has_format: TAKE_MEASUREMENT
```

An example of an `OUTGOING_MESSAGE` that supports variance is:

```
	outgoing_message:
	    has_format: OUT_NAME $new_name
		$new_name type: string
		$new_name description: The new name of the device
```

The general structure of `OUTGOING_MESSAGE` is:

```
	outgoing_message:
		has_format: $variable_1 SOME_TEXT $variable_2 ... (etc.)
		$variable_1 type: string
		$variable_1 description: Description of $variable_1
		$variable_2 type: decimal
		$variable_2 description: Description of $variable_2
		# .
		# .
		# .
		# (etc.)
```

### `has_format: TEMPLATE`
*Required*. A template string containing the characters of a command.

  - `TEMPLATE` must span one line only
  - `TEMPLATE` begins at the first non-whitespace character that occurs after the `format:` key. If a message must begin with a whitespace character then it should be escaped with a backslash (`\`).

- If `TEMPLATE` contains characters that are not supported by the chosen `ENCODING` then a compile-time error will occur
- If `TEMPLATE` contains the device's command `TERMINATOR` then a compile/runtime **warning** will be generated

#### Variables
Variables may be declared within `TEMPLATE`. However, several rules must be followed:

  - Variable declarations begin with a dollar sign (`$`) followed by a `VARIABLE_IDENTIFIER` that begins with a letter followed by letters, numbers, or underscores (i.e. `[A-Za-z][A-Za-z0-9_]*`).
  - A variable declaration is terminated by a single space or semicolon (`;`). Using a semicolon is reccomended if the format string does not require a literal sapce after the declaration's location (e.g. `foo$a;bar`, rather than `foo$a bar`, which would introduce a space after `$a`'s value in the output string).
  - If a literal `$` symbol is required in `TEMPLATE` then it must be escaped with a backslash (`\$`).
  - The same `VARIABLE_IDENTIFIER` may be used multiple times within `TEMPLATE`. At runtime, the output implementation will copy the sole supplied value for `VARIABLE_IDENTIFIER` to the specified locations within `TEMPLATE`.
  - Each `VARIABLE_IDENTIFIER` in `TEMPLATE` must have a corresponding `VARIABLE_IDENTIFIER description:` key in the `outgoing_command_format:`. An invalid `VARIABLE_IDENTIFIER`, or the absence of a `VARIABLE_IDENTIFIER description: ` key will result in a compile error.
  
The absence of a `template:` key for a message format specification will result in a compile error. An invalid, or multi-line `TEMPLATE` will result in a compile error.

### `$VARIABLE_IDENTIFIER description: VARIABLE_DESCRIPTION`
*Required, if `$VARIABLE_IDENTIFIER` was declared in `TEMPLATE`*. A human-readable description of `$VARIABLE_IDENTIFIER`'s purpose. This must be supplied if `$VARIABLE_IDENTIFIER` was declaraed in `TEMPLATE`; otherwise, a compile error will occur. If `$VARIABLE_IDENTIFIER` was not declared in `TEMPLATE` (as in, it's a redundant description) then a compile error will also occur.

### `$VARIABLE_IDENTIFIER type: VARIABLE_TYPE (string|int|decimal) (default: string)`
*Optional. However, `$VARIABLE_IDENTIFER` must be declared in `TEMPLATE`.* The data type of values assigned to the `$VARIABLE_IDENTIFIER` defined in the `TEMPLATE`.

`VARIABLE_TYPE` must have a value of either `string`, `int`, or `decimal`. If supplied, `VARIABLE_TYPE` is used as a type annotation in output implementations. If the `$VARIABLE_IDENTIFIER type: ` key is not supplied then the variable's type is assumed to be `string`. If a `VARIABLE_IDENTIFIER type: ` key is specified but `$VARIABLE_IDENTIFIER` could not be found in `TEMPLATE` then a compile error will occur. An invalid value for `VARIABLE_TYPE` will also result in a compile error.

## `EXPECTED_RESPONSE` Specification
`EXPECTED_RESPONSE` describes the format of messages recieved from the device after sending an outgoing command.

It is fundamentally assumed that `scig` is a high-level application for processing text—not binary—device responses. Binary signals recieved from the device shall be decoded according to the device's `encoding:` key (e.g. `ASCII`) until the `terminator:` (e.g. `\r\n`) pattern is reached. The resulting string, not including the terminator, is assumed to be the full, raw response from the device.

The raw response is parsed according to the definitions in the `incoming_response_template:` section of a command. If the response does not match the specified pattern or data types then a runtime error will occur.

For example, the specification of a response that is always the same is:

```
incoming_response_template:
	pattern: OK
```

If the device does not respond with "`OK`" then a runtime error will occur.

An example of a response that needs to be parsed for a single variable would be:

```
incoming_response_template:
	pattern: NEW_NAME_IS (.+)
	$1 identifier: new_name
	$1 description: The device's new name
```
If the device does not respond with, for example, "`NEW_NAME_IS FOO_DEVICE`" then a runtime error will occur.

An example of a response that needs to be parsed for multiple variables would be:

```
incoming_response_template:
	pattern: OLD_NAME_WAS (.+?) NUMBER_OF_NAME_CHANGES (\d+)
	$1 identifier: old_name
	$1 description: The old name of the device
	$2 identifier: number_of_name_changes
	$2 desctiption: The number of times the name has changed
	$2 type: int
```

If the device does not respond with, for example, "`OLD_NAME_WAS FOO NUMBER_OF_NAME_CHANGES 3`" then a runtime error will occur. Also, because the second capture group's type is `int` but `\d+` may also match decimals (e.g. `3.3`) a runtime error would still occur for a response of "`OLD_NAME_WAS FOO NUMBER_OF_NAME_CHANGES 3.3`". This is because, even though the response matches the specified `pattern`, the capture group could not be parsed into an `int` datatype.

### Specification Keys

### `pattern: PATTERN`
The expected pattern of characters that is expected to be recieved from the device in response to a command. `PATTERN` must be a valid regular expression. The ECMAScript flavour of regex shall be used. The raw response from the device will be matched against this regular expression. If a match cannot be found then a runtime error will occur.

#### Capture Groups
ECMAScript regex supports capture groups of the form `(`*expr*`)`. Capture groups may be used in `PATTERN` to indicate that the character pattern should be captured, parsed, and returned by output implementations. There are several considerations to using capture groups:

- For each capture group in `PATTERN`, there must be corresponding `$`*n* `identifier` and `$`*n* `description` keys (see below) where *n* is the index (within `PATTERN`) of the capture group.
- Optionally, a `$`*n* `type:` key may be defined for each capture group. 

### `$`*n* `identifier: CAPTURE_GROUP_IDENTIFIER`

*Required, if an n<sup>th</sup> capture group exists in `PATTERN`*. The programmatic name of the text captured by the *n*<sup>th</sup> capture group of `PATTERN`. Like all other programmatic identifiers in `scig`, `CAPTURE_GROUP_IDENTIFIER` must begin with a standard alphabetic letter followed by alphanumeric characters. Words within `CAPTURE_GROUP_IDENTIFIER` should be separated with underscores (e.g. `my_capture_group_name`).

If `PATTERN` does not contain an *n*<sup>th</sup> capture group but one of these  `$`*n* `identifier:` keys was delcared then a compile warning will occur. If `PATTERN` contains an *n*<sup>th</sup> capture group but the corresponding `$`*n* `identifier:` key was not defined then a compile error shall occur. An invalid, or absent, `CAPTURE_GROUP_IDENTIFIER` will result in a compile error. A duplicate `CAPTURE_GROUP_IDENTIFIER` that has already been defined elsewhere within the `EXPECTED_RESPONSE` will result in a compile error.

### `$`*n* `description: CAPTURE_GROUP_DESCRIPTION`

*Required, if an n<sup>th</sup> capture group exists in `PATTERN`*. A human-readable description of the data captured by the *n*<sup>th</sup> capture group.

If `PATTERN` does not contain an *n*<sup>th</sup> capture group but an `$`*n* `description:` key is defined then a compile warning will occur. If `PATTERN` contains an *n*<sup>th</sup> capture group but a `$`*n* `description:` key is not defined, or `CAPTURE_GROUP_DESCRIPTION` is blank, then a compile error will occur.

### `$`*n* `type: CAPTURE_GROUP_TYPE (string|int|decimal) (default: string)`

*Optional, but there must be an n<sup>th</sup> capture group in `PATTERN`*. The data type of the text captured by the *n*<sup>th</sup> capture group of `PATTERN`. The captured text will be parsed into the `CAPTURE_GROUP_TYPE` at runtime.

`CAPTURE_GROUP_TYPE` must have a value of `string`, `int`, or `decimal`. If the `$`*n* `type:` key is not supplied then `CAPTURE_GROUP_TYPE` shall default to `string`. If `CAPTURE_GROUP_TYPE` is blank or has an invalid value then a compile error will occur. If `PATTERN` does not contain an *n*<sup>th</sup> capture group but an `$`*n* `type:` key is defined then a compile warning will occur. At runtime, if data recieved by the *n*<sup>th</sup> capture group cannot be parsed into `type` then a runtime error will occur.

# `scig` Output Behaviors
The output from `scig` is command dependent. In general, subcommands to `scig start` will—if passed valid arguments and inputs—start an ongoing process of some sort. For this initial implementation, the only supported subcommand is `http`.

## `scig start http` Behaviors
`scig start http` will start a HTTP server (`SERVER`) that listens for requests on the TCP port specified by the `--port` flag (`PORT`).

- The `scig start http` processes uses the `<input_file>` and `<com_port>` arguments to `scig start http` to create a serial connection to the device
- Once a connection to the device has been opened, the process will open a TCP port (identified by `PORT`) and continuously listen for incoming messages as a `SERVER`
- The `SERVER` is a standard HTTP server and will respond as per the `HTTP/1.1` specification
- `SERVER` supports `application/xml`, `application/json`, and `application/html` response formats
- `SERVER` supports `application/x-www-form-urlencoded` and `application/json` request formats
- Most of the paths and methods supported by `SERVER` shall depend on the supplied `DEVICE_SPEC`
- Regardless of the `DEVICE_SPEC`'s contents, `SERVER` shall generate a `200` (`OK`) response to a `GET` request for its root (`/`)
- `SERVER`'s root (`/`) page exposes information about the device that the `SERVER` is controlling and the structure of other requests that `SERVER` supports 
- `SERVER` listens for all incoming TCP messages regardless of source, it does not do any kind of message filtering in this implementation

### `SERVER` API
`SERVER`'s API is mostly dictated by the `COMMAND_DESCRIPTION`s within the supplied `DEVICE_SPEC`. The main exception to this is the root (`/`) page, which describes—either programatically, in the case of `xml` and `json`, or human-readably, in the case of `http` formats—the API of the server.

Each `COMMAND_DESCRIPTION` in the `DEVICE_SPEC` is exposed as a resource on `SERVER`. The following behaviors apply:

- The command's `identifier` is used as the path for the resource. For example, an identifier of `get_device_name` will be exposed at `http://address:PORT/get-device-name`
- When `SERVER` recieves a `GET` request for the resource, it will send an outgoing command, specified in the `OUTGOING_MESSAGE` part of the `COMMAND_DESCRIPTION`, to the device and handle the response from the device according to the `INCOMING_COMMAND_FORMAT` description. It will then produce a response `TODO: Spec for response based on format specification`
- Specify how arguments are dealt with