# ARTY A7 I2C BME280

This project involves the seamless integration of the BME280 sensor using the I2C (Inter-Integrated Circuit) protocol into the Arty A7-100T FPGA platform. The BME280 is a versatile environmental sensor capable of measuring temperature, humidity, and barometric pressure.

### Implementation

The implementation includes establishing communication between the FPGA and the BME280 sensor through the I2C interface. The FPGA, acting as the master device, initiates data exchange with the BME280 to acquire real-time environmental data. The acquired data is then processed and utilized within the FPGA environment for various applications.

## References

- [Pressure Sensor BME280 Datasheet](https://www.mouser.com/datasheet/2/783/BST-BME280-DS002-1509607.pdf)
- [Artix-7 100T CSG234 Constraints](https://github.com/Digilent/digilent-xdc/blob/master/Arty-A7-100-Master.xdc)
