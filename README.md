# Investigating the Applicability of In-Network Computing to Industrial Scenarios

This repository contains our implementations of the coordinate transformation for different platforms.

## Publication

* Ike Kunze, René Glebke, Jan Scheiper, Matthias Bodenbenner, Robert H. Schmitt, and Klaus Wehrle: *Investigating the Applicability of In-Network Computing to Industrial Scenarios*. In Proceedings of the 4th IEEE International Conference on Industrial Cyber-Physical Systems (ICPS), IEEE, 2021.

If you use any portion of our work, please consider citing our publication.

```
@Inproceedings {2021-kunze-coordinate-transformation,
   author = {Kunze, Ike and Glebke, René and Scheiper, Jan and Bodenbenner, Matthias and Schmitt, Robert H. and Wehrle, Klaus},
   title = {Investigating the Applicability of In-Network Computing to Industrial Scenarios},
   booktitle = {Proceedings of the 4th IEEE International Conference on Industrial Cyber-Physical Systems (ICPS)},
   year = {2021},
   month = {May},
   publisher = {IEEE},
   doi = {XX.XXXX/XXX}
}
```

## Content

Folder | Purpose
--- | --- 
``measurement_code`` | Accompanying measurement code
``transform_spherical_netronome`` | P4 source code for the Netronome SmartNICs 
``transform_spherical_tofino`` | P4 source code for the Intel Tofino
``transform_spherical_userspace`` | Reference userspace implementation 


## License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.