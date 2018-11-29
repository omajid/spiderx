# spiderx

This is an [GNU Emacs](https://www.gnu.org/software/emacs/) package that contains utilities to make it easier to work with licenses.

In particular, it provides commands to automatically download standardized text for all software licenses included in the [SPDX License List](https://spdx.org/licenses/).

Please note that the authors of this package are not lawyers. This package provides technical functionality for working with licenses. You should speak to your own lawyer before actually selecting a license.

## Installing

Until this package lands in a package repository, use Emacs's package manager to install this package:

```
git clone https://github.com/omajid/spiderx
M-x package-install-file RET spiderx.el RET
```

## Using

This package provides a useful number of features for getting license texts:

- `spiderx-add-license-file` will prompt the user for selecting a license (using a SPDX identifier) and the prompt the user for the file to save the license in.

- `spiderx-insert-license` will prompt the user for selecting a license (using a SPDX identifier) and then insert the license in the current buffer.

- `spiderx-show-license` will prompt the user for selecting a license (using a SPDX identifier) show the contents and some other information about the license.

## Authors

* **Omair Majid** - *Initial work* - [omajid](https://github.com/omajid)

See also the list of [contributors](https://github.com/omajid/spiderx/contributors) who participated in this project.

## License

Copyright © 2018 Omair Majid <omair.majid@gmail.com>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
