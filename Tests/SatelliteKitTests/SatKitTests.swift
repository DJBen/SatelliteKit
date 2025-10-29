/* ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
 ║ SatKitTests.swift                                                                                ║
 ║                                                                                                  ║
 ║ Created by Gavin Eadie on Jan07/17 ... Copyright 2017-25 Ramsay Consulting. All rights reserved. ║
 ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝ */

// swiftlint statement_position

import Foundation
@testable import SatelliteKit
import Testing

struct SwiftTests {
    @Test func version() {
        print(SatelliteKit.version)
    }

    @Test func prop1() {
        do {
            let elements = try Elements("ISS (ZARYA)",
                                        "1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999",
                                        "2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577")

            print(elements.debugDescription())

            print("mean altitude    (Kms): \((elements.a₀ - 1.0) * EarthConstants.Rₑ)")

            let propagator = selectPropagator(tle: elements)

            let pv1 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0)
            print(pv1.debugDescription())
            print(String(format: "radius1 %10.1f", pv1.position.magnitude()))

            let pv2 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0 + 1.0 / 60.0)
            print(pv2.debugDescription())
            print(String(format: "radius2 %10.1f", pv2.position.magnitude()))
            print(String(format: "r2 - r1 %10.1f", (pv2.position - pv1.position).magnitude()))

            let pv3 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0 + 2.0 / 60.0)
            print(pv3.debugDescription())
            print(String(format: "radius3 %10.1f", pv3.position.magnitude()))
            print(String(format: "r3 - r2 %10.1f", (pv3.position - pv2.position).magnitude()))

        } catch {
            print(error)
        }
    }

    @Test func prop2() {
        do {
            let tle = try Elements("INTELSAT 39 (IS-39)",
                                   "1 44476U 19049B   19348.07175972  .00000049  00000-0  00000+0 0  9993",
                                   "2 44476   0.0178 355.6330 0000615 323.6584 210.9460  1.00270455  1345")

            print(tle.debugDescription())

            print("mean altitude    (Kms): \((tle.a₀ - 1.0) * EarthConstants.Rₑ)")

            let propagator = selectPropagator(tle: tle)

            let pv1 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0)
            print(pv1.debugDescription())
            print(String(format: "radius1 %10.1f", pv1.position.magnitude()))

            let pv2 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0 + 1.0 / 60.0)
            print(pv2.debugDescription())
            print(String(format: "radius2 %10.1f", pv2.position.magnitude()))
            print(String(format: "r2 - r1 %10.1f", (pv2.position - pv1.position).magnitude()))

            let pv3 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0 + 2.0 / 60.0)
            print(pv3.debugDescription())
            print(String(format: "radius3 %10.1f", pv3.position.magnitude()))
            print(String(format: "r3 - r2 %10.1f", (pv3.position - pv2.position).magnitude()))

        } catch {
            print(error)
        }
    }

    @Test func azEl() {
        let jdate = Date().julianDate
        print("  Julian Ddate: \(jdate)")

        let moonCele = lunarGeo(julianDays: jdate)
        print(" Moon (RA/Dec): \(moonCele)°")

        let azelx = azel(time: Date(), site: LatLon(+42.0, -84.0), cele: moonCele)
        print("       (Az/El): \(azelx)°")
    }

    @Test func conversion() {
        let sat = Satellite(
            "ISS (ZARYA)",
            "1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999",
            "2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577"
        )

        #expect(abs(JD.epoch2000 - sat.minsAfterEpoch(sat.julianDay(JD.epoch2000))) < 1e-7)
        #expect(abs(999.9 - sat.julianDay(sat.minsAfterEpoch(999.9))) < 1e-10)
    }

    @Test func issAzimuthElevation() {
        do {
            // Create ISS satellite with updated TLE
            let satellite = Satellite(
                "ISS (ZARYA)",
                "1 25544U 98067A   25224.47423135  .00010254  00000+0  18430-3 0  9994",
                "2 25544  51.6349  28.0780 0001172 181.8871 178.2114 15.50477111523893"
            )

            let formatter = ISO8601DateFormatter()
            let observationTime = formatter.date(from: "2025-08-15T05:11:51-07:00")!

            // Observer location: lat 37.4253°, lon -122.1399° (Palo Alto, CA area)
            let observerLocation = LatLonAlt(37.4253, -122.1399, 0.0)

            // Get satellite position at observation time
            let aziEleDist = try satellite.topPosition(julianDays: observationTime.julianDate, observer: observerLocation)

            print("Computed Az: \(aziEleDist.azim)°, El: \(aziEleDist.elev)°")

            // Assert expected azimuth 139° (SE) and elevation 80°
            // Allow some tolerance for the calculations
            #expect(abs(aziEleDist.azim - 139.0) < 5.0, "Azimuth should be approximately 139° (SE)")
            #expect(abs(aziEleDist.elev - 80.0) < 5.0, "Elevation should be approximately 80°")

        } catch {
            print("Test failed with error: \(error)")
            #expect(Bool(false), "Test should not throw an error")
        }
    }
}
