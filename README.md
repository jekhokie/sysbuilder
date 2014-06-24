# SysBuilder

SysBuilder is a virtual data center configuration tool that allows for automatic
provisioning of a cloud-based data center based on user-selected components.

## Installation & Configuration

Once cloning the project, copy the sample files:

```bash
cp config/categories.yml.sample config/categories.yml
cp config/components.yml.sample config/components.yml
cp config/compute_providers.yml.sample config/compute_providers.yml
```

Edit the above copied files for the information specific to your software needs based on the
following schemas:

* categories.yml

```json
:<CATEGORY>:
  :category: "<CATEGORY_TAG>"
```

Where:
* `<CATEGORY>`: Name of the category that will be displayed in the web interface
* `<CATEGORY_TAG>`: Tag for the category used internally to decide which components can
be configured within the <CATEGORY> field

***

* components.yml

```json
:<COMPONENT_CATEGORY>:
  :<COMPONENT_NAME>:
    :tag:      "<COMPONENT_TAG>"
    :category: "<CATEGORY_TAG>"
    :versions:
      - "<VERSION>"
      - "<VERSION>"
```

Where:
* `<COMPONENT_CATEGORY>`: Name of the group within which this component falls
* `<COMPONENT_NAME>`: Actual name of the component that will show up in the web interface
* `<COMPONENT_TAG>`: Tag for the component that is used for provisioning scripts to identify the specific component
* `<CATEGORY_TAG>`: Category to which this component belongs and can be configured within
* `<VERSION>`: Versions of the component that can be auto-provisioned by the provisioning scripts

***

* compute_providers.yml

```json
:<PROVIDER_NAME>:
  :<COMPUTE_RESOURCE_NAME>:
    :cpu:  "<COMPUTE_CPUS>"
    :mem:  "<COMPUTE_MEMORY>"
    :disk: "<COMPUTE_DISK>"
    :cost: "<COMPUTE_COST_HR> /hr"
```

Where:
* `<PROVIDER_NAME>`: Name of the provider that will be interfaced with for creating the virtual instances
* `<COMPUTE_RESOURCE_NAME>`: Name of the resource for identification in the UI
* `<COMPUTE_CPUS>`: Number of CPUs that the compute resource will contain
* `<COMPUTE_MEMORY>`: Amount of memory (in MB) that the compute resource will contain
* `<COMPUTE_DISK>`: Amount of disk storage (in GB) that the compute resource will contain
* `<COMPUTE_COST_HR>`: The cost of running this instance per hour

## Screenshots

### Manifest Explorer

Main screen that shows a listing of all the created manifests (virtual data center definitions) within the system. This list can be picked from to use/provision existing manifests, and shows the associated costs for running each.

![Sysbuilder explore](img/explore.png "Manifest Explorer")

### Manifest Builder

The meat and potatoes of the Sysbuilder tool. This is where you start constructing your software mappings to virtual resource types. Make sure to pay careful attention to the numbers - your system can get more expensive than you think!

![Sysbuilder build](img/build.png "Manifest Builder")
