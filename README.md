# vbox-cli
Interfaz por línea de comandos interactiva para el manejo de VirtualBox

# Instalación
Para poder usar esta aplicación, simplemente ejecute el script `setup.sh` que se encuentra en la raíz de este mismo proyecto.

De momento los sistemas son los siguientes:
* Arch Linux
* Ubuntu/Debian

## Describir en qué consiste el proyecto
* vbox-cli es un *CLI* ( *Command Line Interface ) que te permite utilizar el sistema virtualizador Oracle VirtualBox de una manera más sencilla e intuitiva que la que nos brinda ya el *frontend gráfico* y su propio *CLI*, de hecho, este proyecto aspira ser, ayudándose de ambas partes, un *software* que permite utilizar de manera más rápida e eficiente VirtualBox

* Este proyecto nació de la "necesidad" ( digamos personal ), de ver que en algunas ocasiones la interfaz gráfica se notaba tosca y con falta de opciones, de las cuales se encontraban en *VBoxManage* ( el *CLI* que proporciona VirtualBox ). No obstante, aunque *VBoxManage* fuera más completo en opciones, su eso es complejo y llevar a cabo una tarea como puede ser la creación de una máquina virtual, llegaba a ser tediosa y repetitiva.

* Por la tanto, esta Interfaz aspira a resolver los problemas que se nos presentan en la actual *CLI* proporcionada, pero de una forma responsiva e interactiva, para que el usuario que estaba acostumbrado a realizar gestiones con máquinas virtuales desde la *GUI* ( *Graphical User Interface* ) no se sienta perdido y lo encuentre "familiar", conservando la potencia de las opciones brindadas por el *CLI*

## Mostrar el resultado final, que se vea funcionando
*Recorrer las acciones de la interfaz explicando brevemente ( más todavía ) lo que hace cada acción*

### vm_actions
* **start_virtual_machines**: Esta acción permite levantar las máquinas virtuales disponibles en el *host*, de una manera rápida y digo rápida, porque se nos puede dar la ocasión de que en determinados ocasiones queramos levantar más de una máquina virtual, *"explicar el problema del arranque simultáneo en el frontend gráfico"*

* **poweroff_virtual_machines**: Esta acción permite apagar una o múltiples máquinas de forma simultánea, con un procedimiento similar al de *start_virtual_machines*

* **pause_virtual_machine**: Esta acción permite poner en un estado alterado a las máquinas, **pausando** su ejecución sin necesidad de apagarlas 

* **delete_virtual_machine:** Esta acción permite borrar las máquinas virtuales seleccionadas

* **resume_virtual_machine**: Esta acción permite reanudar las máquinas que estaban en estado pausado, así reanudando todos los procesos de la máquina

* **create_virtual_machine**: Esta acción permite crear una máquina virtual, preguntando al usuario cosas como el nombre o las especificaciones que desea asignarle a esta

* **import_virtual_machine:** Esta acción permite importar un archivo *.ova* o *.ovf* ( siendo estos prácticamente idénticos ), teniendo la posibilidad de cambiar las características de esta antes de importarla

* **export_virtual_machine:** Esta acción permite exportar una máquina virtual en formato *OVA*, pudiendo exportar varias de una sola toma

* **autoinstall_virtual_machine:** Esta acción permite realizar una instalación desatendida, es decir, automática. *"explicar problema de la auto instalación en las versiones actuales de VirtualBox"*

### modify_vm
* **change_vm_cpu_cores**: Esta acción permite modificar la cantidad de núcleos que se le comparten a la máquina virtual durante su ejecución

* **change_vm_network_settings:** Esta acción permite modificar la configuración de las tarjetas de red virtuales de las máquinas virtuales, permitiendo a su vez habilitar ( o deshabilitar ) interfaces.

* **change_vm_shared_ram:** Esta acción permite modificar la cantidad de memoria RAM que se le comparte a la máquina virtual durante su ejecución

### miscellaneous
* **vbox-top**: Esto más que una acción, se podría considerar como un aplicación complementaría a *vbox-cli*. El propósito de *vbox-top* es mostrar una lista con información básica junto a nivel de carga de las máquinas virtuales que se estén ejecutando en la sesión del usuario. A diferencia de *vbox-cli*, esta aplicación esta escrita en *Python*, el cual es uno de los lenguajes más populares entre los desarrolladores, principalmente su facilidad y su gran comunidad. *Entrar en detalle el porque de la selección de Python*

## Comentar las tecnologías usadas
* Para el desarrollo de esta aplicación se han utilizado 2 lenguajes de programación, *Bash Shell Script* y *Python*.

* **vbox-top**: El *CLI* esta escrito en *Bash*, se decidió desarrollarlo en este lenguaje debido a su universalidad en los sistemas UNIX, ya sea tanto en *Linux* o *OSX*. Aunque no se recomienda el desarrollo de aplicaciones en este lenguaje, por razones como la falta de estructura de datos simples ( arrays, HashMaps, Clases, etc. ) o su velocidad de ejecución, no ha supuesto ningún impedimento en el desarrollo de la misma. Ya que uno de los motivos determinantes que se decidió escoger el este lenguaje fue la capacidad de de concatenación de la salida de varios comandos, permitiendo así poder integrar el *CLI* de VirtualBox de forma sencialla, aparte de como se ha mencionado anteriormente la universalidad en los sistemas UNIX

* **vbox-top**: La aplicación complementaria es un servidor web que se ejecuta de manera local, cuyo backend esta escrito en *Python*. La decisión de utilizar este lenguaje en pos de otros como puede ser *PHP*, aparte de las ya mencionadas en el punto anterior es por decisión personal. La comunidad de Python es más grande y es más sencillo de mantener y escalar aplicaciones escritas en *Python* que en *PHP*. Aparte de que el *framework* utilizado ( *Flask* ) es muy liviano y modular, permitiendo en un futuro ampliar su funcionalidad sin mucho esfuerzo.

## Explicar como se ha desarrollado, detallando decisiones durante esta
La aplicación se ha desarrollado teniendo en mente un diseño modular, que aunque muestre una funcionalidad básica con 16 acciones *out of the box*, el usuario (siendo un usuario medio o desarrollador) pueda añadir sus propias acciones o modificar las ya existentes, de esta manera ampliando la funcionalidad de la aplicación.

Parte de los problemas de la interfaz gráfica como del *CLI* son resueltos de manera eficiente utilizando características avanzadas de *Bash* ( expansiones, sustituciones de procesos, descriptores de ficheros, etc. ).

*vbox-cli* funciona con ***espacios de trabajo o namespaces***, esto quiere decir que cada acción estará dentro de un directorio el cual describe el propósito de los scripts que contiene en su interior, *poner como ejemplo vm_actions*

Dentro de la aplicación, se detectará si tenemos máquinas virtuales en el directorio el cual VirtualBox habitualmente suele definirlas, en `$HOME/VirtualBox VMs`. En caso de que detecte máquinas, el *CLI* comenzará a cachear la información de la para facilitar el acceso de su información a otras acciones que la requieran. Si ya estaban cacheadas, para la ejecución y sigue con el flujo principal del *CLI*

Una vez cacheadas las máquinas, se listaran todos los *namespaces* definidos que se encuentran en la carpeta *scripts* del directorio raíz del proyecto. Cuando el usuario realice la selección, se listaran todas las acciones disponibles junto con una descripción del mismo, en el caso de que contenga alguna.

Y ahora para demostrar sus escalabilidad vamos a escribir y añadir unas cuantas acciones a la interfaz. *Añadir script de aumentar discos y un script diciendo hola*

En cuanto a la aplicación web, se ha utilizado un *framework* para el desarrollo de aplicaciones web llamado *Flask*. *Flask* es un framework minimalista que permite crear desde cero con una base solida aplicaciones web de forma rápida y sencilla. También permite la ampliación de funcionalidades mediante módulos que se pueden encontrar tanto en su página oficial o en la comunidad ( github ).

La web se divide en 2 rutas, la principal "/" y la asignada para la API "/api".

Lo más característico de la aplicación es que para su creación se tubo diseñar una *API* sencilla desde cero. Mientras el usuario tenga abierta la ágina de *vbox-top*, cada 750ms, la *API* recolecta los *PID* de las máquinas virtuales que se estén ejecutando, luego de encontrar el proceso, busca a que máquina esta asociada ese proceso y una vez lo encuentra se dirige al directorio principal de la máquina y recolecta la información de esta a través de su fichero *.vbox*, ya que es más fácil parsear la información a través de ahí que desde el fichero ya generado por la ejecución de *vbox-cli*.

Ya recolectada toda la información, la *API* devolverá la información en formato *JSON*, cuyo contenido sera la información de las máquinas que se estén ejecutando en ese preciso instante con sus respectivas características.

Por último, cuando se accede a la página web, se carga un fichero JavaScript el cuál recoge la información de la API y la muestra dentro de una tabla HTML.

