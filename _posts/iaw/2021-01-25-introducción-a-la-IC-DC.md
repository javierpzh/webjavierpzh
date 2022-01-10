---
layout: post
---

En este artículo vamos a ver una pequeña introducción a la **integración y el despliegue continuo**.

- **Integración continua (IC) / Continuous integration (CI):** es el nombre que se le da a la automatización de las labores de compilación, test y análisis estático del código. Consiste en hacer integraciones automáticas de un proyecto lo más a menudo posible para así poder detectar fallos cuanto antes. Entendemos por integración la compilación y ejecución de pruebas de todo un proyecto.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_la_IC-DC/IC.png" />

- **Entrega continua (EC) / Continuous delivery (CD):** sería el siguiente paso. En realidad se puede considerar una extensión de la *Integración Continua*, en la cuál, el proceso de entrega de *software* se automatiza para permitir implementaciones fáciles y confiables en la producción, en cualquier momento.

- **Despliegue continuo (DC) / Continuous deployment (CD):** en este punto ya no hay intervención humana, sino que la automatización es el eje central. Para lograr este propósito, el *pipeline* de producción tiene una serie de pasos que deben ejecutarse en orden y de forma satisfactoria. Si alguno de estos pasos no finalizan de forma esperada, el proceso de despliegue no se llevará a cabo.

<img src="https://raw.githubusercontent.com/javierpzh/webjavierpzh/master/assets/img/images/iaw_introducción_a_la_IC-DC/EC-DC.png" />

Explicados los diferentes conceptos, habríamos terminado el contenido del *post*.
