import smtplib


fromaddr = 'jp@jp.jp'
toaddrs = ['unko@127.0.0.1']

# Add the From: and To: headers at the start!
msg = ("From: %s\r\nTo: %s\r\n\r\n" % (fromaddr, ", ".join(toaddrs)))
msg = msg + '''Delivered-To: jp.ne.co.jp@gmail.com
Received: by 10.140.101.131 with SMTP id u3csp2531478qge;
        Fri, 7 Jul 2017 05:30:00 -0700 (PDT)
X-Received: by 10.200.51.172 with SMTP id c41mr64792353qtb.71.1499430600045;
        Fri, 07 Jul 2017 05:30:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1499430599; cv=none;
        d=google.com; s=arc-20160816;
        b=PDsmWK7HEwIV36SnyJEfZ097cvAIo/YaiXRiwQnXCYQrKYdCBcvZJIPir404PS1Kma
         hd47v8FrZGpq591ykbMCB0sg7kylZo+IthqAyFZK7jfrXcXkdh1507ckL5iJiz+DwIGA
         9+OgKPFgZs+W3+ZKhkGbNn73KtfN8iHu8G/FC+HPhbAxTz7uy6AHtUmXKfWAhoGDsGzk
         q8amkzvWMuT6rQHR/L9vATJxANMdiZhCfiXfQegCgCCXVD4DDs//7OhyFl2cNT4qV5p3
         C0b/6Zuz6qdW/7thAyweEQ0ghFZjxMLDKDi2yvwcLYeoG5QMhE7mG9iWmoSN3xjecn+A
         pGkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:message-id:in-reply-to:references:subject:auto-submitted:to
         :from:dkim-signature:arc-authentication-results;
        bh=Xe3Hva+K80E6Eu5oS4Xo4PrtdVOFKD/oYOB9kRQSKGk=;
        b=eztrVlaWAqEUvHzYpyerdQvv/BjB5YRLH9kzIp0i0U8xVQhYGsds0M6KtCJKqAB7Tt
         PuyYvzEsuxqvjSGdt8pMcDGyc83EKVVnOQ6NCbCdGwwM15fIrFxfknIQ41j6WIVeZ0wc
         1GGCCkie4IMm0Qwek1wSD+h9m6gXr9ynnqBz6vS0yMcfzs4f0gbR2eunJNhJdoUYov5L
         9iawNK08SQuetuN6AWVpgRYhcQ3YrwrGhiHUj2oHNHUkP8F3UPmw702L4Cu44VyctOl9
         2GjyXww66gsKbb04GXSGIbpF7ETouN4FZ5F0eWGgvv1CqxSRg3t1jLLKJhVbumDE7M8V
         7zew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@googlemail.com header.b=SrlYCWvE;
       spf=pass (google.com: best guess record for domain of postmaster@mail-qt0-x245.google.com designates 2607:f8b0:400d:c0d::245 as permitted sender) smtp.helo=mail-qt0-x245.google.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
Return-Path: <>
Received: from mail-qt0-x245.google.com (mail-qt0-x245.google.com. [2607:f8b0:400d:c0d::245])
        by mx.google.com with ESMTPS id u48si81639qtu.388.2017.07.07.05.29.59
        for <jp.ne.co.jp@gmail.com>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 05:29:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of postmaster@mail-qt0-x245.google.com designates 2607:f8b0:400d:c0d::245 as permitted sender) client-ip=2607:f8b0:400d:c0d::245;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@googlemail.com header.b=SrlYCWvE;
       spf=pass (google.com: best guess record for domain of postmaster@mail-qt0-x245.google.com designates 2607:f8b0:400d:c0d::245 as permitted sender) smtp.helo=mail-qt0-x245.google.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
Received: by mail-qt0-x245.google.com with SMTP id m54so525642qtb.9
        for <jp.ne.co.jp@gmail.com>; Fri, 07 Jul 2017 05:29:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=googlemail.com; s=20161025;
        h=from:to:auto-submitted:subject:references:in-reply-to:message-id
         :date;
        bh=Xe3Hva+K80E6Eu5oS4Xo4PrtdVOFKD/oYOB9kRQSKGk=;
        b=SrlYCWvEa3R3olv0fCIHADfEjpv6urEh5yj+1WdM7owkBVUx3SiMyt2s56opmSx7bj
         BLdM5QUuh3gOIa2XMjetEXfrfrlQBhycw+re5OeVCSKaqoa+Kahhk+kijHNKMkXuWEO1
         151VrjnwB+TeIQ9i5Vii58V5hzQ5V2PGo5wtXfbRM2sfkK/sqYbk7nscUBo/u1Bkqr2q
         ilmV/2fEV3uYBmyWtLpBZJ0n4fdsAVdL8KCVoNPKzlPzYL9PnqSbBcpsgXWvvyUZBqrx
         0CVMx/6wO+047APKysZOTKB+i4uVKIve7Xs+KGr/hWivoediL+/BU0qM4HinZTZ3vhrk
         twlw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:auto-submitted:subject:references
         :in-reply-to:message-id:date;
        bh=Xe3Hva+K80E6Eu5oS4Xo4PrtdVOFKD/oYOB9kRQSKGk=;
        b=pITsTCQ40a+BJ9rTttLJi2sYW8Fjl0l/xUeq9QEau8+fmxIJe5tcrdWQ8v12NIr6WR
         4As+sM0TQIpmq8MotRw5OYx3TRZY0I+3Vfpy4K19b8Jkb9TAP+22W0njaWuhjX+8/nk7
         rfQ3X60BlxXNwQDOjzYIXYSqcMu12sMVRShFz8uAC+if7CE85zhZSLqK/0y+Zsn6mZN/
         y/hY1ndnqWtS+8CxZIwjK4IrHxx8idHIZDcw7wPZDIAj3K57snVvPDYBEiF4GY6r1Tiv
         z2atkADfLwdrsTii7wb3e/87d0PCwXOzDNBwKjVUCt72atlIvvNXDQs4ugUCDgKPUVpJ
         gmIA==
X-Gm-Message-State: AKS2vOw8iqqQnF3Euh0Sl9DW016O1o5uiwbIypeOxzeqeDJGr3z/Lizy
  U+RlG9JKTM9yrFc53+Bz2ufAuTH2KaqXEFdl/L3Q
X-Received: by 10.55.72.81 with SMTP id v78mr61737683qka.133.1499430599496;
        Fri, 07 Jul 2017 05:29:59 -0700 (PDT)
Content-Type: multipart/report; boundary="001a114a83783f795c0553b9643a"; report-type=delivery-status
Return-Path: <>
Received: by 10.55.72.81 with SMTP id v78mr64941872qka.133; Fri, 07 Jul 2017
 05:29:59 -0700 (PDT)
Auto-Submitted: auto-replied
Subject: Delivery Status Notification (Delay)
References: <CAGvY8TYJmkJ1=ws5N6MC-c5Mufe5kjM4d3DqoCuj_tP9C_gdtw@mail.gmail.com>
In-Reply-To: <CAGvY8TYJmkJ1=ws5N6MC-c5Mufe5kjM4d3DqoCuj_tP9C_gdtw@mail.gmail.com>
Message-ID: <595f7ec7.5148370a.b6d0b.ce96.GMRIR@mx.google.com>
Date: Fri, 07 Jul 2017 05:29:59 -0700 (PDT)
X-Mailer: Exmail Mailer - **CIDMTI0anAubmUuY28uanBAZ21haWwuY29t**
X-Campaign: Exmail-anAubmUuY28uanBAZ21haWwuY29t.MTI0
X-CampaignID: Exmail-MTI0

--001a114a83783f795c0553b9643a
Content-Type: multipart/related; boundary="001a114a83783f88340553b9643b"

--001a114a83783f88340553b9643b
Content-Type: multipart/alternative; boundary="001a114a83783f885c0553b9643c"

--001a114a83783f885c0553b9643c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64

CioqIOmFjeS/oeacquWujOS6hiAqKgoKYm91bmNlQHNpbXVsYXRvci5hbWF6b25zZXMuY29tIOOB
uOOBruODoeODvOODq+OBrumFjeS/oeS4reOBq+S4gOaZgueahOOBquWVj+mhjOOBjOeZuueUn+OB
l+OBvuOBl+OBn+OAgkdtYWlsIOOBryA0NiDmmYLplpPlho3oqabooYzjgZfjgIHphY3kv6Hjgafj
gY3jgarjgYvjgaPjgZ/loLTlkIjjga/jgYrnn6XjgonjgZvjgZfjgb7jgZnjgIIKCgoK5b+c562U
OgoKcmVhZCBlcnJvcjogZ2VuZXJpYzo6ZmFpbGVkX3ByZWNvbmRpdGlvbjogcmVhZCBlcnJvciAo
MCk6IGVycm9yCg==
--001a114a83783f885c0553b9643c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable


<html>
<head>
<style>
* {
font-family:Roboto, "Helvetica Neue", Helvetica, Arial, sans-serif;
}
</style>
</head>
<body>
<table cellpadding=3D"0" cellspacing=3D"0" class=3D"email-wrapper" style=3D=
"padding-top:32px;background-color:#ffffff;"><tbody>
<tr><td>
<table cellpadding=3D0 cellspacing=3D0><tbody>
<tr><td style=3D"max-width:560px;padding:24px 24px 32px;background-color:#f=
afafa;border:1px solid #e0e0e0;border-radius:2px">
<img style=3D"padding:0 24px 16px 0;float:left" width=3D72 height=3D72 alt=
=3D"=E3=82=A8=E3=83=A9=E3=83=BC=E3=82=A2=E3=82=A4=E3=82=B3=E3=83=B3" src=3D=
"cid:icon.png">
<table style=3D"min-width:272px;padding-top:8px"><tbody>
<tr><td><h2 style=3D"font-size:20px;color:#212121;font-weight:bold;margin:0=
">
=E9=85=8D=E4=BF=A1=E6=9C=AA=E5=AE=8C=E4=BA=86
</h2></td></tr>
<tr><td style=3D"padding-top:20px;color:#757575;font-size:16px;font-weight:=
normal;text-align:left">
<a style=3D'color:#212121;text-decoration:none'><b>bounce@simulator.amazons=
es.com</b></a> =E3=81=B8=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AE=E9=85=
=8D=E4=BF=A1=E4=B8=AD=E3=81=AB=E4=B8=80=E6=99=82=E7=9A=84=E3=81=AA=E5=95=8F=
=E9=A1=8C=E3=81=8C=E7=99=BA=E7=94=9F=E3=81=97=E3=81=BE=E3=81=97=E3=81=9F=E3=
=80=82Gmail =E3=81=AF 46 =E6=99=82=E9=96=93=E5=86=8D=E8=A9=A6=E8=A1=8C=E3=
=81=97=E3=80=81=E9=85=8D=E4=BF=A1=E3=81=A7=E3=81=8D=E3=81=AA=E3=81=8B=E3=81=
=A3=E3=81=9F=E5=A0=B4=E5=90=88=E3=81=AF=E3=81=8A=E7=9F=A5=E3=82=89=E3=81=9B=
=E3=81=97=E3=81=BE=E3=81=99=E3=80=82
</td></tr>
</tbody></table>
</td></tr>
</tbody></table>
</td></tr>
<tr style=3D"border:none;background-color:#fff;font-size:12.8px;width:90%">
<td align=3D"left" style=3D"padding:48px 10px">
=E5=BF=9C=E7=AD=94:<br/>
<p style=3D"font-family:monospace">
read error: generic::failed_precondition: read error (0): error
</p>
</td>
</tr>
</tbody></table>
</body>
</html>

--001a114a83783f885c0553b9643c--
--001a114a83783f88340553b9643b
Content-Type: image/png; name="icon.png"
Content-Disposition: attachment; filename="icon.png"
Content-Transfer-Encoding: base64
Content-ID: <icon.png>

iVBORw0KGgoAAAANSUhEUgAAAJAAAACQCAYAAADnRuK4AAAACXBIWXMAABYlAAAWJQFJUiTwAAAA
GXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAADtNJREFUeNrsnVtsFNcZx8/Mzq7t
2vhCAsZujJdiEYgq2W1UVFqpGGq1olIL5aVtWglTtX7oS+0HnvIQ89QHS7X70gfSi6OqfWkLliIF
NbLKkiZKBapYS00aKgJrzMVA5RsYjO3d6fnmst7Lmdm575md75OGY7y7np05v/l/l3PmjCDLMkFD
c2oingI0BAgNAUJDgNAiaFK1drx6sruVNifoliz4dQr+aTw/m8KuCYcJQWdhGjgTdDtl4e2XC8Eq
aNMUsiXsvogBROHp0yBo8ehPztANQEqXtghYjQGkKU/GQ3icAJbRNwpYBrs/XDHQRMDwgPVq7WEG
0NDMFkKFgHGqQJr6LIbw/OiAlblJClga8QlOgU6E9Px0axvYcYaCLbPirygBFhRAyRo9fy0F7pEF
mGEmWSuliqBc2KTFtD2KFupSRVAApViBLFr4SxXowvi3SplkVUsVQSkQTjqqfiapb6BcU6EBiMID
6nML+5E7qIa9ACmI0Xh0X3yWJy5oyQ33ALVif3FrpyhEo7wD1If9xLW9oYUZqEBojm0YFQjNjfWj
AqG5sV6eAerF/qld8xUgbRoHGv82y6sCYfwTDsvwChAqEAKECoQAVTeIRkOAHFs/9g0ChIYAVQ0g
nIUYAnMz8QwVCG3ZzYd9A2j1ZDfGP+GwNJcAoYXGlngFCBUIFQgNFQgVCA0VCC2KCoTjYCEwt4tA
+AlQC3YP97bs9g/4ApC2lB1ajcc/fioQzgOKQPzjJ0CoQKhAqEBoqEBo5pZCBUKrqlVeYGpkYEJT
lNIVsjJkfDqDChRe82KdRqkCPLB+jL545GHG629RiAYZn8QaECqQYv0VXj+lQDY+nV+oyOlKD2Lj
NhLvSJLY9p1EiElEfv6M5OhGNjdJ7uljIm9ukNwqbbNqi+baLgcBkBUlKa0l2AZI2vFZUtfz+aLf
CXUNJEY3MICq1OQsBWt1BQHjVoFGBpzGMbYAijVvL4PHioFKwWeNAAPLriwobW5FXSQ/u7xQ9HvM
wPxVIKuZVNoNQE7gsQNnYRt/aa8lwHJPV6iibSJiLgGypkDj045dGLguQXNT1bBKgBW5ROoys3mX
WROAcaFAM05dmCBJJLFnP/vFRD3J9XyByLsPEPJkiQhPFrWWskp/VtoADAL7IsBKXi8FLLf2LB/8
Q4sKZD+AtgwQZFwQx7DgyX7zx0Tevkv9fzsNmFl/AIBapbtfXyPCwn2tnaftM7WtAmBlgX4epjX1
Z74AS/OgQKwv0V1RfajbKnUX+av6lUNb8JhZUyuRm9SvKHcxlAyAWpyvKmCFmaQZYNXIJL16TILk
Mpsq+hJWa0CJrh5j13XgkDdniP4tuT1pDBh08IOM2s7f0tri/wcJmJ1ShQcKNhOEC+u28PmMXehA
7qUdnWz16TuidHxQlgdMa0sX4zMETFM03wEzKVVABvn8xr+dgrTkL0AjA1YzqYxdtxfvYrsucEee
qU9QgIEr3Ch1kWuBAAZgNfR+hax9dMWJu0v7rUBWAZqgsAFE6euz1/c15+SmZjFmfND0KjIKOHN9
R0OXgeixWh4wYg6Y15kkKFQiuZ9CdJUzBbIOEFyTvYsri8fvPLhDWhoaSXPzC4ZvrkuyYxF51x4i
7629AfxKgOUzSRelCrggIRu0qULcKJBicw/mlLbZJH6BwNmoaKjEPlE0PZOsVKqgrXjjmmFwL21v
J+v2APJdgSzb2vM18mjxkXql5XLrwEqZ1EoSkTq6jdWnPUnQzAHLUoUWZy4RMX2pvB7V3OY+BhoZ
gAcjD5LSeV/j06ZqxZ6ROD49Sv89TSysH3zz7s38z81SPMEMnF/qYRcNIZv46ncRFIuW62VnqeDG
4CJ1XAMaGQBwLhB17tcbQADdgNRr9DWZbil7AKkQTdINpOEsMbgBDdTn/v/uV6x1xA3UB4YrSBPO
frUFEQzvsDrSIDlhGEsUBit85jCFaNgeQMVqxASpUH2MYiDD0XYoGvYeQSLsBubU5RsF0w5LL1at
1RlAKkRLGkiQKr1lVX3goAzT9lcOofq4qE2VB9I73QBkZS3LJecAbYGU0eZA77n36N6nhS+1NDSV
i0zSZLSds6Jh6AJrRqhgcWqMUwVKuweoAKTP/flmT1d718i2xm0amcWJKMz10UermWl7gEMWUXFj
FlUoUxJA97tJ/V3dF7bv/O2Jg++utHXu6Pzti/WNK4Vpu9FcHx6HLCIWB2Ucikbac4B0OzB19yc7
EvXX8mm70VwfEs4hi7DEQWKLI4D63XwXL+9MPaz7YtOi4V6859CTOIgxZ6pw9N7IHC4qfjkIgNT4
uKvHRH0wbffdjZmrEKsGVH0F0hcVN5vrg0MWAQHUZhxI50RR/O/J3cM2AmfdUkYvSF4elNFcHzAc
sggoDqKZLyQxrLtG1rKbXXMP74zv3rWb1I8MePI9vHJh/aZzfXDIwnuDKbsGc8eNhjWeaVAtPl60
u7eU7zFQnVnREIcsAnVjML2DZWub60r7+Kl3E/Y9AYgGzj8ynOuDQxb+AWQwsBozmN6xvPZUaZ+s
PrG3o/FpHxVobKg13pnsNlQfLBoGHgcZDWtkczmnLsxXBRolIjtvxyGLarqx8mxsVXNhNt3YZf8A
GhuCS+DnzAPDIYuAAEoauLHiQFompCgte/LU1I3BfWMwfecIdV+mKb/bNH7CsOaAQxYBKhBjmmtJ
QXFDBSjf34sri6TjxY5CYFL5rXzBDB8AGhsCMo8bvo6Bc3XjIG1YQ1/CJitvzZaoS9RtCoLwkSYA
U3aA8VKBhs1eFG5cw8pzgNmYcPs/5W6sZQugnCAsdO7ovBiX4pM9f8m879W+3QBkKjFwG4quRHqg
h0D5FwcxAYJhjbkbys+NhLy5c+ruqNf7dgNQxWH1PEQlPjoPlBYAImBu3Rg7EysZ1kj5sW83ADle
yndrsYJbbMCgRJ9o0Foo2XeobdsuLAuwANLOE+t+fBjWyC489G3fzgAaG/J1Uo++fo/RnZiGgDW2
RjZ4BxVnuTEY1gCAvFhU3EsFqmovVQQMIGpq01qYhN6mtjUMmGEcZP+u1UAA4npaobpAwRIRjE52
CWB5FYvXW1sdjUPLdR0g4pWL5ecCFrHa1vYv3gAK9WVcCbAit1joJnkGTLvdh7WqR6z1hVZUoCAN
FonSA32GW8gDxVkmqcRB+cy3KJ3f5A2gaJeZCwEzyiSrUKpQ9sEAiKbzL9eMAilzo3fvV69grSPg
Kg9q7efA3GQ1ShVmCQIMPZ05l+IFIPs1IFj/+ehrZVegsoLql44R8epFIn78YWREzI9SRYXzB+v/
cACQOoXDPjyFi4ezsggKkYWTgIAZZJKwgmyF5Yn7eXFhtgGyung4QFSL7qwqmWS59frxPcRAALIx
sUyGOzjQQmO+A5Qfp7GTSaD5YTOhBAgCQTQubCmUACmLbNsxjH/8skw4FUh/BIDN+glaOABykoV1
26b06kWaxp+2lLqKjEpqlAzSclnJWju2LkCamXpwXjgAyEkNSFMVWCTb9BZneqLED85HGh64j451
jqDYCr+PXfqTm2edcaFASac7ghXW4eCzUDAsqaQKn6ZJ7Mo73j7hRqveKlmgsiBTR8XYC55XoXSQ
3nIAT97oMUAxNvb2r53WycINkAIKlWKJbnoV1euYB2CBOhLMEbY97YLxvAp4Xlh+rM5HoJSbMK0s
QAG3ivcdJbH3HSj1mXPhByjfMVoV1bOrF6A5cMjzuTowbqeM3UHnwgNP5ihIH3/oeaXcaJEE5nth
iUD7aj3rF/xVAchLxckeeS2Yaar6rdp0A2VSXLJH6mm3eAru2Oa+MwgQQ84hJqjGXRqgSpBVKiBR
NXDt3vw/Bt8AslsH4mYimT69oarfAUD69s9I7uAxV9/FfrF1kRuA7CpQLwmLQf1ED4L1zMoodimZ
A213QVBwbRC4QxnCiRoJtz9RXKM12OadxGDcAMSN6WCUBs5QEhAha2LNZTaDrWgO9KV8bAKzJ+GO
h0pxlhKPQZr9t9/Zhkg5Fgq7FWihnsaTCxNkWbb+7rEhmSuKIA46+C21cyFLSv/dt7lEkCkp85oq
dTKFUfrrL+3XtCxMuhM/uOC0Ir3HrzTeLkDpULkxP0CiqgQT33zpaKjzUEhze4tXtXWd9Z05J/h1
Puy6MFhP5vdRBgg6EarBSkdr03DL3uO0og7DOWn1uah6sdWDUsGyn+dDtEnyJNEeOBd1g7nbAFKZ
qyqIp1yBCkMr3tSZ0vwApEI0SEyeoxopNaLBsjI2NfeJmvHRFoJoT8f03JuvE6zsxUDlMVE/UYuL
sIHT7tPaXoLGi52lF/0on2m82Y1qY0OFQPX9Y2Hz4HsPnx9rTQjkUJtEmiSR7NsmYfdGWoFs2NdO
/GB4fe3ZeBnBokB2NqggvdqqPnb+WHtcab/YlsDud29H/Lgj1RsF8sA2czK5t7qh/Ky3b98tfs8/
v77zrPZjv9YeRi74UKBw+BAjH66ulFbkKgvaFmRHOXdpBKjyyUnZBAyC/u4I4ON7pswtQFKijkjx
OG0TfgKWLMgiS7daACwdGYBEMabAokJTF5SCZYjZQGM5YGErVSzVLECCIJBYPJFXGQCIQxdZCbAy
9/jOg/Xv31rdbIdSBQeZZKqmAIpJEt3iefdUAwHqUkEnTcE/v/jO9/o21p+3/6FkFKKzMR50qQLi
n8maAai+sSlNImyVShUA2Kttdddff/kz8x6VKgY1wKMZREcRsEcb4vzrvznX77JUMavBkwrieyNA
HCQPInXt4NKpi0+7KFWoQbPPdR8EqMoWg6RBUmBRwClJHuy7nICBqSZATg/0cpjVJaYqi5I8QFtr
FthgKtg3fvhTyApO2fzY6Xf/+OYk7yeSHhu4kcnNjfUv09PaDrBAqcKmzWoX2ig95lAkHUFfEqNE
XW7W6jjVTBjg0Qy+53Ep7iot79Y2iGuSoVDZIHdGYcgQdUTdyhjNDPFpaVqfzMubLkMzjCIGvUNN
mvsrxDa/gvfQ94ZpvTsv0+bQzDsPNAZixA1JzaXpVy8o1FTIwCk8nkEPXM8SPf4JBAgtEibiKUBD
gNAQIDQECC2C9n8BBgBAP0FWplWQxQAAAABJRU5ErkJggg==
--001a114a83783f88340553b9643b--
--001a114a83783f795c0553b9643a
Content-Type: message/delivery-status

Reporting-MTA: dns; googlemail.com
Arrival-Date: Thu, 06 Jul 2017 03:51:31 -0700 (PDT)
X-Original-Message-ID: <CAGvY8TYJmkJ1=ws5N6MC-c5Mufe5kjM4d3DqoCuj_tP9C_gdtw@mail.gmail.com>

Final-Recipient: rfc822; bounce@simulator.amazonses.com
Action: delayed
Status: 4.4.2
Remote-MTA: dns; simulator-in.amazonses.com. (72.21.215.231, the server for
 the domain simulator.amazonses.com.)
Diagnostic-Code: smtp; read error: generic::failed_precondition: read error (0): error
Last-Attempt-Date: Fri, 07 Jul 2017 05:29:59 -0700 (PDT)
Will-Retry-Until: Sun, 09 Jul 2017 03:51:31 -0700 (PDT)

--001a114a83783f795c0553b9643a
Content-Type: message/rfc822

DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:mime-version:date:message-id:subject:to;
        bh=4TQHWagkyBQ074LrEpJhaVov7ltDPE7w/YfxZW/OQnw=;
        b=XPAd+0iomaacQGA2AmwUjCofOtV8spAje8I45eJQhbYa1GOEYxilm7feAK37sVcqKh
         pXZJ0eYzpiyzekzwcCE+6Av3bm+rBwe21hG0iTwAFAPIe2/Q/VdIN4lbR71yUFOP+V1D
         uBEb20ujIvU/fWdVzk3Zmmv0HyjpL7oDnPTFjDekmfUDDrZgqGfiIjLBowlVFJ2RJSCG
         up4os7UQ2NfcRXNUmwO8DW+05PqX2qVjzD7+854mf+ZvPstSzBKZXeq9beTFGmTC66ez
         AfE58VG7ndk3uzvJkuUrlPQ6TR3RZAi8BXjb7USVcKir6BdMO2saBg74z15HXSPC9J4c
         edIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:mime-version:date:message-id:subject:to;
        bh=4TQHWagkyBQ074LrEpJhaVov7ltDPE7w/YfxZW/OQnw=;
        b=p14c21W0mZY1F3IZYFN+R1b89JeNKPUUXRg8wjGbAVxbO/LTm/DVtSeHfe2FoK7QgO
         Fj2C+QAAf8TPK05yT0isjYKbm6UpQmo+FV3haqWSOQ35KLG7jT9MHnjEWHxM5ZO9//iJ
         gk7JCdldvNJX3sP/naZGLxKglQyO/JTxKAXx0jJhFGzAjtEhmplOdnBtn6LDfG/gleIV
         GiNiCbQ6s1xOlEjATPaTUEjooC3TJF+jAaNa8RHOvK4Ds3YcuFVLABuWmNCaDgcy9jl/
         ogUhRLvV/feruQGKVjdTF/w8RbMEojMZZcKCgf0pDrrGT92V9K2yjoV5b9jXOAc6monB
         ej9Q==
X-Gm-Message-State: AKS2vOwWrQ5px5aajdPdkmi6/Y2fjQZOdSTl9PAj7u7V+00q0DNHnPZK
  gYWuMDoPO1I3EKLkJTnbK4UtuOIvAA==
X-Received: by 10.55.72.81 with SMTP id v78mr55350801qka.133.1499338291860;
 Thu, 06 Jul 2017 03:51:31 -0700 (PDT)
Received: from 1058052472880 named unknown by gmailapi.google.com with
 HTTPREST; Thu, 6 Jul 2017 06:51:31 -0400
From: =?UTF-8?B?5rGg55Sw6YGU6YOO?= <jp.ne.co.jp@gmail.com>
X-Mailer: Airmail (442)
MIME-Version: 1.0
Date: Thu, 6 Jul 2017 06:51:31 -0400
Message-ID: <CAGvY8TYJmkJ1=ws5N6MC-c5Mufe5kjM4d3DqoCuj_tP9C_gdtw@mail.gmail.com>
Subject: bounce@simulator.amazonses.com
To: bounce@simulator.amazonses.com
Content-Type: multipart/alternative; boundary="001a114a837848dabe0553a3e6de"

--001a114a837848dabe0553a3e6de
Content-Type: text/plain; charset="UTF-8"

bounce@simulator.amazonses.com

--001a114a837848dabe0553a3e6de
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<html><head><style>body{font-family:Helvetica,Arial;font-size:13px}</style>=
</head><body style=3D"word-wrap:break-word"><div id=3D"bloop_customfont" st=
yle=3D"font-family:Helvetica,Arial;font-size:13px;color:rgba(0,0,0,1.0);mar=
gin:0px;line-height:auto"><a href=3D"mailto:bounce@simulator.amazonses.com"=
>bounce@simulator.amazonses.com</a></div><br><div id=3D"bloop_sign_14993382=
60565947136" class=3D"bloop_sign"></div></body></html>

--001a114a837848dabe0553a3e6de--

--001a114a83783f795c0553b9643a--'''

print("Message length is", len(msg))

server = smtplib.SMTP('127.0.0.1', 2525)
server.set_debuglevel(1)
server.sendmail(fromaddr, toaddrs, msg)
server.quit()
