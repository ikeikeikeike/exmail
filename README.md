# Exmail

> Exmail in Elixir@1.3.4 Erlang OTP 18.3 N/A
>
> Exmail in Elixir@1.4.2 Erlang OTP 18.3 A
>
> Exmail in Elixir@1.4.2 Erlang OTP 19.3 A
>
> Exmail in Elixir@1.4.5 Erlang OTP 20.0 A
>
> Exmail in Elixir@1.5.3 Erlang OTP 20.2 A


## Installation

#### Erlang & Elixir

- http://elixir-lang.github.io/install.html

#### Wkhtmltoimage

###### Convert html to image

- http://wkhtmltopdf.org/

## Development

For upload and download templates, write file as a symbolic link which phoenix is able to see template's link from priv/static/uploads.

```
$ (cd priv/static; ln -s ../../uploads .)
```

### Check syntax  using credo

Should avoid to show some warning using running credo command.

```shell
$ mix credo
```
